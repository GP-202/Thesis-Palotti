clear all
close all
clc

% Importare i dati dal file .CSV
data = readtable('landmarks_data.csv');

% Estrarre le colonne dei keypoints sinistro
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

angoloSinistroCaviglia = angoloSinistroCaviglia';


% Plot dell'angolo destro rispetto ai frame
frames = data.Frame;
time1= frames/30;
figure
plot(time1, angoloSinistroCaviglia, 'b-', 'LineWidth', 2);

% Personalizzare il grafico
title('Left Ankle Angle');
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
angoloSinistroCavigliaFiltrato = filtfilt(b, a, angoloSinistroCaviglia);

% Plot dell'angolo destro filtrato rispetto ai frame
figure
plot(time1, angoloSinistroCavigliaFiltrato, 'r-', 'LineWidth', 2);

% Personalizzare il grafico
title('Left Ankle Angle (Filtered)');
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
finestra_selezionata = angoloSinistroCavigliaFiltrato(index1:index2);

% Plot della finestra selezionata
figure;
plot(time1(index1:index2), finestra_selezionata, 'k-', 'LineWidth', 2);
title('Left Ankle Angle in time');
xlabel('Time [s]');
ylabel('Angle [°]');
grid on;
