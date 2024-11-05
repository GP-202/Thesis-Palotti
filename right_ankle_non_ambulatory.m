clear all
close all
clc

% Importare i dati dal file .CSV
data = readtable('landmarks_data.csv');

% Estrarre le colonne dei keypoints destro
destroKneeX = data.RIGHT_KNEEX;
destroKneeY = data.RIGHT_KNEEY;
destroKneeZ = data.RIGHT_KNEEZ;

destroAnkleX = data.RIGHT_ANKLEX;
destroAnkleY = data.RIGHT_ANKLEY;
destroAnkleZ = data.RIGHT_ANKLEZ;

destroFootIndexX = data.RIGHT_FOOT_INDEXX;
destroFootIndexY = data.RIGHT_FOOT_INDEXY;
destroFootIndexZ = data.RIGHT_FOOT_INDEXZ;

% Calcolare l'angolo destro tra knee-ankle e ankle-foot index
numFrames = length(destroKneeX);

angoloDestroCaviglia = zeros(numFrames, 1);

for i = 1:numFrames
    kneeAnkleVector = [destroAnkleX(i) - destroKneeX(i), destroAnkleY(i) - destroKneeY(i), destroAnkleZ(i) - destroKneeZ(i)];
    ankleFootIndexVector = [destroFootIndexX(i) - destroAnkleX(i), destroFootIndexY(i) - destroAnkleY(i), destroFootIndexZ(i) - destroAnkleZ(i)];

    dotProduct = dot(ankleFootIndexVector, kneeAnkleVector);
    normKneeAnkle = norm(kneeAnkleVector);
    normAnkleFootIndex = norm(ankleFootIndexVector);

    angoloDestroCaviglia(i) = acosd(dotProduct / (normKneeAnkle * normAnkleFootIndex));
end

% Definire il frame rate e calcolare il tempo corrispondente
frames = data.Frame;
fps = 30;
time = frames / fps;

% Calcolare il numero massimo di frame disponibile
maxFrame = min(720, numFrames); % Selezionare il limite di tempo tra 720 o l'ultimo frame disponibile

% Selezionare i dati fino al massimo numero di frame 
timeLimited = time(1:maxFrame);
angoloLimited = angoloDestroCaviglia(1:maxFrame);

% Plot dell'angolo del ginocchio destro rispetto al tempo
figure
plot(timeLimited, angoloLimited, 'b-', 'LineWidth', 2);

% Personalizzare il grafico
title('Right Ankle Angle');
xlabel('Time [s]');
ylabel('Angle [°]');
xlim([timeLimited(1) timeLimited(end)]); 
grid on;

%% FILTRAGGIO BUTTERWORTH

% Frequenza di campionamento
fs = fps; % 30 FPS

% Frequenza di taglio desiderata
fc = 4; % 4 Hz

% Calcolare le frequenze normalizzate
Wn = fc / (fs / 2);

% Progettare il filtro Butterworth
order = 4; % Ordine del filtro
[b, a] = butter(order, Wn);

% Filtrare i dati dell'angolo del ginocchio destro
angoloDestroCavigliaFiltrato = filtfilt(b, a, angoloLimited);

% Plot dell'angolo destro filtrato rispetto al tempo
figure
plot(timeLimited, angoloDestroCavigliaFiltrato, 'k-', 'LineWidth', 2);

% Personalizzare il grafico
title('Right Ankle Angle (Filtered)');
xlabel('Time [s]');
ylabel('Angle [°]');
xlim([timeLimited(1) timeLimited(end)]); 
grid on;
hold on

%% REGRESSIONE LINEARE

% Regressione lineare sui dati dell'angolo destro
coeffs = polyfit(timeLimited, angoloDestroCavigliaFiltrato, 1); % Regressione lineare di primo grado
angoloRegressione = polyval(coeffs, timeLimited); % Calcolare i valori della retta di regressione
save("retta_destro", "angoloRegressione");

% Calcolare del coefficiente angolare e del valore medio totale
coefficienteAngolare = coeffs(1); % coefficiente angolare della retta
valoreMedioTotale = mean(angoloRegressione); % valore medio della retta

% Visualizzare i risultati
fprintf('Il coefficiente angolare della retta di regressione è: %.4f\n', coefficienteAngolare);
fprintf('Il valore medio totale della retta di regressione è: %.4f\n', valoreMedioTotale);

% Plot della regressione lineare
plot(timeLimited, angoloRegressione, 'r--', 'LineWidth', 2);

% Personalizzare del grafico
title('Right Ankle Angle and Linear Regression');
xlabel('Time [s]');
ylabel('Angle [°]');
legend('Right Ankle Angle', 'Linear Regression');
xlim([timeLimited(1) timeLimited(end)]);
grid on;
