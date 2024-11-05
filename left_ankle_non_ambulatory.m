clear all
close all
clc

% Importare i dati dal file .CSV
data = readtable('landmarks_data.csv');

% Estrarre le colonne dei keypoints sinistri
sinistroKneeX = data.LEFT_KNEEX;
sinistroKneeY = data.LEFT_KNEEY;
sinistroKneeZ = data.LEFT_KNEEZ;

sinistroAnkleX = data.LEFT_ANKLEX;
sinistroAnkleY = data.LEFT_ANKLEY;
sinistroAnkleZ = data.LEFT_ANKLEZ;

sinistroFootIndexX = data.LEFT_FOOT_INDEXX;
sinistroFootIndexY = data.LEFT_FOOT_INDEXY;
sinistroFootIndexZ = data.LEFT_FOOT_INDEXZ;

% Calcolare l'angolo sinistro tra knee-ankle e ankle-foot index
numFrames = length(sinistroKneeX);

angoloSinistroCaviglia = zeros(numFrames, 1);

for i = 1:numFrames
    kneeAnkleVector = [sinistroAnkleX(i) - sinistroKneeX(i), sinistroAnkleY(i) - sinistroKneeY(i), sinistroAnkleZ(i) - sinistroKneeZ(i)];
    ankleFootIndexVector = [sinistroFootIndexX(i) - sinistroAnkleX(i), sinistroFootIndexY(i) - sinistroAnkleY(i), sinistroFootIndexZ(i) - sinistroAnkleZ(i)];

    dotProduct = dot(ankleFootIndexVector, kneeAnkleVector);
    normKneeAnkle = norm(kneeAnkleVector);
    normAnkleFootIndex = norm(ankleFootIndexVector);

    angoloSinistroCaviglia(i) = acosd(dotProduct / (normKneeAnkle * normAnkleFootIndex));
end

% Definire il frame rate e calcolare il tempo corrispondente
frames = data.Frame;
fps = 30; 
time = frames / fps;

% Calcolare il numero massimo di frame disponibile
maxFrame = min(720, numFrames); % Selezionare il limite di tempo tra 720 o l'ultimo frame disponibile

% Selezionare i dati fino al massimo numero di frame 
timeLimited = time(1:maxFrame);
angoloLimited = angoloSinistroCaviglia(1:maxFrame);

% Plot dell'angolo della caviglia sinistra rispetto al tempo
figure
plot(timeLimited, angoloLimited, 'b-', 'LineWidth', 2);

% Personalizzare il grafico
title('Left Ankle Angle');
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

% Filtrare i dati dell'angolo della caviglia sinistra
angoloSinistroCavigliaFiltrato = filtfilt(b, a, angoloLimited);

% Plot dell'angolo sinistro filtrato rispetto al tempo
figure
plot(timeLimited, angoloSinistroCavigliaFiltrato, 'k-', 'LineWidth', 2);

% Personalizzare il grafico
title('Left Ankle Angle (Filtered)');
xlabel('Time [s]');
ylabel('Angle [°]');
xlim([timeLimited(1) timeLimited(end)]); 
grid on;
hold on

%% REGRESSIONE LINEARE

% Regressione lineare sui dati dell'angolo sinistro
coeffs = polyfit(timeLimited, angoloSinistroCavigliaFiltrato, 1); % Regressione lineare di primo grado
angoloRegressione = polyval(coeffs, timeLimited); % Calcolare i valori della retta di regressione
save("retta_sinistro", "angoloRegressione");

% Calcolare del coefficiente angolare e del valore medio totale
coefficienteAngolare = coeffs(1); % coefficiente angolare della retta
valoreMedioTotale = mean(angoloRegressione); % valore medio della retta

% Visualizzare i risultati
fprintf('Il coefficiente angolare della retta di regressione è: %.4f\n', coefficienteAngolare);
fprintf('Il valore medio totale della retta di regressione è: %.4f\n', valoreMedioTotale);

% Plot della regressione lineare
plot(timeLimited, angoloRegressione, 'r--', 'LineWidth', 2);

% Personalizzare del grafico
title('Left Ankle Angle and Linear Regression');
xlabel('Time [s]');
ylabel('Angle [°]');
legend('Left Ankle Angle', 'Linear Regression');
xlim([timeLimited(1) timeLimited(end)]); 
grid on;
