clear all
close all
clc

% Importare i dati dal file .CSV
data = readtable('landmarks_data.csv');

% Estrarre le colonne dei keypoints destro
destroHipX = data.RIGHT_HIPX;
destroHipY = data.RIGHT_HIPY;
destroHipZ = data.RIGHT_HIPZ;

destroKneeX = data.RIGHT_KNEEX;
destroKneeY = data.RIGHT_KNEEY;
destroKneeZ = data.RIGHT_KNEEZ;

destroAnkleX = data.RIGHT_ANKLEX;
destroAnkleY = data.RIGHT_ANKLEY;
destroAnkleZ = data.RIGHT_ANKLEZ;

% Calcolare l'angolo destro tra anca-ginocchio e ginocchio-caviglia
numFrames = length(destroHipX);

angoloDestroGinocchio = zeros(numFrames, 1);

for i = 1:numFrames
    hipKneeVector = [destroKneeX(i) - destroHipX(i), destroKneeY(i) - destroHipY(i), destroKneeZ(i) - destroHipZ(i)];
    kneeAnkleVector = [destroAnkleX(i) - destroKneeX(i), destroAnkleY(i) - destroKneeY(i), destroAnkleZ(i) - destroKneeZ(i)];

    dotProduct = dot(hipKneeVector, kneeAnkleVector);
    normHipKnee = norm(hipKneeVector);
    normKneeAnkle = norm(kneeAnkleVector);

    angoloDestroGinocchio(i) = acosd(dotProduct / (normHipKnee * normKneeAnkle));
end


% Definire il frame rate e calcolare il tempo corrispondente
frames = data.Frame;
fps = 30; 
time = frames / fps;

% Calcolare il numero massimo di frame disponibile
maxFrame = min(720, numFrames); % Selezionare il limite di tempo tra 720 o l'ultimo frame disponibile

% Selezionare i dati fino al massimo numero di frame 
timeLimited = time(1:maxFrame);
angoloLimited = angoloDestroGinocchio(1:maxFrame);

% Plot dell'angolo del ginocchio destro rispetto al tempo
figure
plot(timeLimited, angoloLimited, 'b-', 'LineWidth', 2);

% Personalizzare il grafico
title('Right Knee Angle');
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
order = 4; % Ordine del filtro quarto
[b, a] = butter(order, Wn);

% Filtrare i dati dell'angolo del ginocchio destro
angoloDestroGinocchioFiltrato = filtfilt(b, a, angoloLimited);

% Plot dell'angolo destro filtrato rispetto al tempo
figure
plot(timeLimited, angoloDestroGinocchioFiltrato, 'k-', 'LineWidth', 2);

% Personalizzare il grafico
title('Right Knee Angle (Filtered)');
xlabel('Time [s]');
ylabel('Angle [°]');
xlim([timeLimited(1) timeLimited(end)]);
grid on;
hold on

%% REGRESSIONE LINEARE

% Regressione lineare sui dati dell'angolo destro
coeffs = polyfit(timeLimited, angoloDestroGinocchioFiltrato, 1); % Regressione lineare di primo grado
angoloRegressione = polyval(coeffs, timeLimited); % Calcolare i valori della retta di regressione
save("retta_destro", "angoloRegressione");

% Calcolare coefficiente angolare e del valore medio totale
coefficienteAngolare = coeffs(1); % coefficiente angolare della retta
valoreMedioTotale = mean(angoloRegressione); % valor medio della retta

% Visualizzare i risultati
fprintf('Il coefficiente angolare della retta di regressione è: %.4f\n', coefficienteAngolare);
fprintf('Il valore medio totale della retta di regressione è: %.4f\n', valoreMedioTotale);

% Plot della regressione lineare
plot(timeLimited, angoloRegressione, 'r--', 'LineWidth', 2);

% Personalizzare il grafico
title('Right Knee Angle and Linear Regression');
xlabel('Time [s]');
ylabel('Angle [°]');
legend('Knee Angle', 'Linear Regression');
xlim([timeLimited(1) timeLimited(end)]); 
grid on;
