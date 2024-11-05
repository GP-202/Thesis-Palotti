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

% Definiscre il frame rate e calcolare il tempo corrispondente
frames = data.Frame;
fps = 30;
time = frames / fps;

% Calcolare il numero massimo di frame disponibile 
maxFrame = min(720, numFrames); % Selezionare il limite di tepo tra 720 o all'ultimo frame disponibile

% Selezionare i dati fino al massimo numero di frame 
timeLimited = time(1:maxFrame);
angoloLimited = angoloSinistroGinocchio(1:maxFrame);

% Plot dell'angolo del ginocchio sinistro rispetto al tempo
figure
plot(timeLimited, angoloLimited, 'b-', 'LineWidth', 2);

% Personalizzare il grafico
title('Left Knee Angle');
xlabel('Time [s]');
ylabel('Angle [°]');
xlim([timeLimited(1) timeLimited(end)]); % Limita l'asse X ai dati disponibili
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

% Filtrare i dati dell'angolo del ginocchio sinistro
angoloSinistroGinocchioFiltrato = filtfilt(b, a, angoloLimited);

% Plot dell'angolo sinistro filtrato rispetto al tempo
figure
plot(timeLimited, angoloSinistroGinocchioFiltrato, 'k-', 'LineWidth', 2);

% Personalizzare il grafico
title('Left Knee Angle (Filtered)');
xlabel('Time [s]');
ylabel('Angle [°]');
xlim([timeLimited(1) timeLimited(end)]); 
grid on;
hold on

%% REGRESSIONE LINEARE

% Regressione lineare sui dati dell'angolo sinistro
coeffs = polyfit(timeLimited, angoloSinistroGinocchioFiltrato, 1); % Regressione lineare di primo grado
angoloRegressione = polyval(coeffs, timeLimited); % Calcolare i valori della retta di regressione
save("retta", "angoloRegressione");

% Calcolare coefficiente angolare e valore medio totale
coefficienteAngolare = coeffs(1); % coefficiente angolare della retta
valoreMedioTotale = mean(angoloRegressione); % valore medio della retta 

% Visualizzare i risultati
fprintf('Il coefficiente angolare della retta di regressione è: %.4f\n', coefficienteAngolare);
fprintf('Il valore medio totale della retta di regressione è: %.4f\n', valoreMedioTotale);

% Plot della regressione lineare
plot(timeLimited, angoloRegressione, 'r--', 'LineWidth', 2);

% Personalizzare il grafico
title('Left Knee Angle and Linear Regression');
xlabel('Time [s]');
ylabel('Angle [°]');
legend('Left Knee Angle', 'Linear Regression');
xlim([timeLimited(1) timeLimited(end)]); 
grid on;
