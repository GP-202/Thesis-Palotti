clear all
close all
clc

% Importare i dati dal file .CSV
data = readtable('landmarks_data.csv');

% Estrarre le colonne dei keypoints sinistro
sinistroShoulderX = data.LEFT_SHOULDERX;
sinistroShoulderY = data.LEFT_SHOULDERY;
sinistroShoulderZ = data.LEFT_SHOULDERZ;

sinistroHipX = data.LEFT_HIPX;
sinistroHipY = data.LEFT_HIPY;
sinistroHipZ = data.LEFT_HIPZ;

sinistroKneeX = data.LEFT_KNEEX;
sinistroKneeY = data.LEFT_KNEEY;
sinistroKneeZ = data.LEFT_KNEEZ;

% Calcolare l'angolo all'anca sinistro come angolo compreso tra vettori
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

angoloSinistroAnca=180-angoloSinistroAnca;

% Plot dell'angolo destro rispetto ai frame
frames = data.Frame;
time1= frames/30;
figure
plot(time1, angoloSinistroAnca, 'b-', 'LineWidth', 2);

% Personalizzare il grafico
title('Left Hip Angle');
xlabel('Time [s]');
ylabel('Angle [°]');
grid on;

%% FILTRAGGIO GO PRO

% Frequenza di campionamento
fs = 30; % 30 FPS

% Frequenza di taglio desiderata
fc = 4; % 4 Hz

% Calcolare le frequenze normalizzate
Wn = fc / (fs / 2);

% Progettare il filtro Butterworth
order = 4; % Ordine del filtro
[b, a] = butter(order, Wn);

% Filtrare i dati dell'angolo destro anca
angoloSinistroAncaFiltrato = filtfilt(b, a, angoloSinistroAnca);

% Plot dell'angolo destro filtrato rispetto ai frame
figure
plot(time1, angoloSinistroAncaFiltrato, 'r-', 'LineWidth', 2);

% Personalizzare il grafico
title('Left Hip Angle (Filtered)');
xlabel('Time [s]');
ylabel('Angle [°]');
grid on;

%% SCELGO FINESTRA

% Aggiunta della selezione manuale della finestra
disp('Seleziona manualmente la finestra di interesse facendo clic su due punti sull''asse x.');
disp('Premi INVIO dopo aver selezionato i punti.');

[x, ~] = ginput(2);  % Selezionare due punti sull'asse x

% Determina gli indici corrispondenti ai punti selezionati
index1 = find(time1 >= x(1), 1);
index2 = find(time1 >= x(2), 1);

% Estrarre la finestra selezionata
finestra_selezionata = angoloSinistroAncaFiltrato(index1:index2);

% Plot della finestra selezionata
figure;
plot(time1(index1:index2), finestra_selezionata, 'k-', 'LineWidth', 2);
title('Left Hip Angle in time');
xlabel('Time [s]');
ylabel('Angle [°]');
grid on;
