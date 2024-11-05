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

angoloDestroCaviglia = angoloDestroCaviglia';


% Plot dell'angolo destro rispetto ai frame
frames = data.Frame;
time1= frames/30;
figure
plot(time1, angoloDestroCaviglia, 'b-', 'LineWidth', 2);

% Personalizzare il grafico
title('Right Ankle Angle');
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
angoloDestroCavigliaFiltrato = filtfilt(b, a, angoloDestroCaviglia);

% Plot dell'angolo destro filtrato rispetto ai frame
figure
plot(time1, angoloDestroCavigliaFiltrato, 'r-', 'LineWidth', 2);

% Personalizzare il grafico
title('Right Ankle Angle (Filtered)');
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
finestra_selezionata = angoloDestroCavigliaFiltrato(index1:index2);

% Plot della finestra selezionata
figure;
plot(time1(index1:index2), finestra_selezionata, 'k-', 'LineWidth', 2);
title('Right Ankle Angle in time');
xlabel('Time [s]');
ylabel('Angle [°]');
grid on;
