clear all
close all
clc

% Importare i dati dal file .CSV
data = readtable('landmarks_data.csv');

% Estrarre le colonne dei keypoints sinistro
sinistroHipX = data.LEFT_HIPX;
sinistroHipY = data.LEFT_HIPY;
sinistroHipZ = data.LEFT_HIPZ;

sinistroKneeX = data.LEFT_KNEEX;
sinistroKneeY = data.LEFT_KNEEY;
sinistroKneeZ = data.LEFT_KNEEZ;

sinistroAnkleX = data.LEFT_ANKLEX;
sinistroAnkleY = data.LEFT_ANKLEY;
sinistroAnkleZ = data.LEFT_ANKLEZ;

% Calcolare l'angolo sinistro tra anca-ginocchio e ginocchio-caviglia
numFrames = length(sinistroHipX);

angoloSinistroGinocchio = zeros(numFrames, 1);

for i = 1:numFrames
    hipKneeVector = [sinistroKneeX(i) - sinistroHipX(i), sinistroKneeY(i) - sinistroHipY(i), sinistroKneeZ(i) - sinistroHipZ(i)];
    kneeAnkleVector = [sinistroAnkleX(i) - sinistroKneeX(i), sinistroAnkleY(i) - sinistroKneeY(i), sinistroAnkleZ(i) - sinistroKneeZ(i)];

    dotProduct = dot(hipKneeVector, kneeAnkleVector);
    normHipKnee = norm(hipKneeVector);
    normKneeAnkle = norm(kneeAnkleVector);

    angoloSinistroGinocchio(i) = acosd(dotProduct / (normHipKnee * normKneeAnkle));
end

angoloSinistroGinocchio = angoloSinistroGinocchio';


% Plot dell'angolo destro rispetto ai frame
frames = data.Frame;
time1= frames/30;
figure
plot(time1, angoloSinistroGinocchio, 'b-', 'LineWidth', 2);

% Personalizzare il grafico
title('Left Knee Angle');
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
angoloSinistroGinocchioFiltrato = filtfilt(b, a, angoloSinistroGinocchio);

% Plot dell'angolo destro filtrato rispetto ai frame
figure
plot(time1, angoloSinistroGinocchioFiltrato, 'r-', 'LineWidth', 2);

% Personalizzare il grafico
title('Left Knee Angle (Filtered)');
xlabel('Time [s]');
ylabel('Angle [°]');
grid on;

%% SCELGO FINESTRA
% Aggiunta della selezione manuale della finestra
disp('Seleziona manualmente la finestra di interesse facendo clic su due punti sull''asse x.');
disp('Premi INVIO dopo aver selezionato i punti.');

[x, ~] = ginput(2);  % Selezionare due punti sull'asse x

% Determinare gli indici corrispondenti ai punti selezionati
index1 = find(time1 >= x(1), 1);
index2 = find(time1 >= x(2), 1);

% Estrarre la finestra selezionata
finestra_selezionata = angoloSinistroGinocchioFiltrato(index1:index2);

% Plot della finestra selezionata
figure;
plot(time1(index1:index2), finestra_selezionata, 'k-', 'LineWidth', 2);
title('Left Knee Angle in time');
xlabel('Time [s]');
ylabel('Angle [°]');
grid on;
