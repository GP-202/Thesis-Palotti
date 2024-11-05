clear all
close all
clc

% Importare i dati dal file .CSV
data = readtable('landmarks_data.csv');

% Estrai le colonne dei keypoints sinistro
sinistroShoulderX = data.LEFT_SHOULDERX;
sinistroShoulderY = data.LEFT_SHOULDERY;
sinistroShoulderZ = data.LEFT_SHOULDERZ;

sinistroHipX = data.LEFT_HIPX;
sinistroHipY = data.LEFT_HIPY;
sinistroHipZ = data.LEFT_HIPZ;

sinistroKneeX = data.LEFT_KNEEX;
sinistroKneeY = data.LEFT_KNEEY;
sinistroKneeZ = data.LEFT_KNEEZ;

% Calcola l'angolo sinistro tra spalla-anca e anca-ginocchio
numFrames = size(data, 1); 

angoloSinistroAnca = zeros(numFrames, 1);

for i = 1:numFrames
    shoulderHipVector = [sinistroShoulderX(i) - sinistroHipX(i), sinistroShoulderY(i) - sinistroHipY(i), sinistroShoulderZ(i) - sinistroHipZ(i)];
    hipKneeVector = [sinistroKneeX(i) - sinistroHipX(i), sinistroKneeY(i) - sinistroHipY(i), sinistroKneeZ(i) - sinistroHipZ(i)];

    normShoulderHip = norm(shoulderHipVector);
    normHipKnee = norm(hipKneeVector);
    
    shoulderHipVectorNorm = shoulderHipVector / normShoulderHip;
    hipKneeVectorNorm = hipKneeVector / normHipKnee;

    dotProduct = dot(shoulderHipVectorNorm, hipKneeVectorNorm);

    angoloSinistroAnca(i) = acosd(dotProduct);
end

angoloSinistroAnca = 180 - angoloSinistroAnca;

% Definire il frame rate e calcolare il tempo corrispondente
frames = data.Frame;
fps = 30; 
time = frames / fps;

% Calcolare il numero massimo di frame disponibile
maxFrame = min(720, numFrames); % Selezionare il limite di tempo tra 720 o all'ultimo frame disponibile

% Selezionare i dati fino al massimo numero di frame
timeLimited = time(1:maxFrame);
angoloLimited = angoloSinistroAnca(1:maxFrame);

% Plot dell'angolo dell'anca sinistra rispetto al tempo
figure
plot(timeLimited, angoloLimited, 'b-', 'LineWidth', 2);

% Personalizzare il grafico
title('Left Hip Angle');
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

% Filtrare i dati dell'angolo dell'anca sinistra
angoloSinistroAncaFiltrato = filtfilt(b, a, angoloLimited);

% Plot dell'angolo sinistro filtrato rispetto al tempo
figure
plot(timeLimited, angoloSinistroAncaFiltrato, 'k-', 'LineWidth', 2);

% Personalizzare il grafico
title('Left Hip Angle (Filtered)');
xlabel('Time [s]');
ylabel('Angle [°]');
xlim([timeLimited(1) timeLimited(end)]); 
grid on;
hold on

%% REGRESSIONE LINEARE

% Regressione lineare sui dati dell'angolo sinistro
coeffs = polyfit(timeLimited, angoloSinistroAncaFiltrato, 1); % Regressione lineare di primo grado
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
title('Left Hip Angle and Linear Regression');
xlabel('Time [s]');
ylabel('Angle [°]');
legend('Left Hip Angle', 'Linear Regression');
xlim([timeLimited(1) timeLimited(end)]); 
grid on;
