function GUI_EKG_Manual()
    % 1. MEMBUAT MAIN WINDOW
    fig = uifigure('Name', 'Form1', 'Position', [100, 100, 1050, 650]);
    
    % 2. MEMBUAT PANEL KIRI
    leftPanel = uipanel(fig, 'Title', 'Process', 'Position', [10, 10, 150, 630]);
    
    uilabel(leftPanel, 'Text', 'Data', 'Position', [10, 580, 50, 22]);
    uieditfield(leftPanel, 'numeric', 'Position', [10, 555, 60, 22], 'Value', 999);
    uieditfield(leftPanel, 'numeric', 'Position', [10, 525, 60, 22], 'Value', 250);
    
    btnAction = uibutton(leftPanel, 'Text', 'Action', 'Position', [75, 525, 65, 22]);
    uilabel(leftPanel, 'Text', 'NData', 'Position', [10, 500, 50, 22]);
    
    % MENGHUBUNGKAN VARIABEL KE KOTAK INPUT (T1)
    uilabel(leftPanel, 'Text', 'T', 'Position', [10, 470, 50, 22]);
    in_T1 = uieditfield(leftPanel, 'numeric', 'Position', [40, 445, 60, 22], 'Value', 60);  uilabel(leftPanel, 'Text', 'T1', 'Position', [10, 445, 30, 22]);
    uieditfield(leftPanel, 'numeric', 'Position', [40, 415, 60, 22], 'Value', 1);  uilabel(leftPanel, 'Text', 'T2', 'Position', [10, 415, 30, 22]);
    uieditfield(leftPanel, 'numeric', 'Position', [40, 385, 60, 22], 'Value', 3);  uilabel(leftPanel, 'Text', 'T3', 'Position', [10, 385, 30, 22]);
    uieditfield(leftPanel, 'numeric', 'Position', [40, 355, 60, 22], 'Value', 15); uilabel(leftPanel, 'Text', 'T4', 'Position', [10, 355, 30, 22]);
    uieditfield(leftPanel, 'numeric', 'Position', [40, 325, 60, 22], 'Value', 7);  uilabel(leftPanel, 'Text', 'T5', 'Position', [10, 325, 30, 22]);
    
    % MENGHUBUNGKAN VARIABEL KE KOTAK INPUT (Delay)
    uilabel(leftPanel, 'Text', 'Delay', 'Position', [10, 290, 50, 22]);
    in_D1 = uieditfield(leftPanel, 'numeric', 'Position', [60, 265, 60, 22], 'Value', 180); uilabel(leftPanel, 'Text', 'Delay1', 'Position', [10, 265, 50, 22]); 
    in_D2 = uieditfield(leftPanel, 'numeric', 'Position', [60, 235, 60, 22], 'Value', 80);  uilabel(leftPanel, 'Text', 'Delay2', 'Position', [10, 235, 50, 22]); 
    in_D3 = uieditfield(leftPanel, 'numeric', 'Position', [60, 205, 60, 22], 'Value', 100); uilabel(leftPanel, 'Text', 'Delay3', 'Position', [10, 205, 50, 22]); 
    in_D4 = uieditfield(leftPanel, 'numeric', 'Position', [60, 175, 60, 22], 'Value', 300); uilabel(leftPanel, 'Text', 'Delay4', 'Position', [10, 175, 50, 22]); 
    in_D5 = uieditfield(leftPanel, 'numeric', 'Position', [60, 145, 60, 22], 'Value', 15);  uilabel(leftPanel, 'Text', 'Delay5', 'Position', [10, 145, 50, 22]);
    
    % 3. MEMBUAT TAB GROUP
    tabGroup = uitabgroup(fig, 'Position', [170, 10, 870, 630]);
    tabProsses = uitab(tabGroup, 'Title', 'Prosses');
    tabMallat = uitab(tabGroup, 'Title', 'Mallat');
    tabFilter = uitab(tabGroup, 'Title', 'Filter Bank');
    tabZero = uitab(tabGroup, 'Title', 'Zero-corss');
    tabGradient = uitab(tabGroup, 'Title', 'Gradient');
    tabDetection = uitab(tabGroup, 'Title', 'Detection');
    
    tabGroup.SelectedTab = tabFilter;
    
    % 4. MENYIAPKAN GRAFIK AXES
    axInput = uiaxes(tabFilter, 'Position', [10, 450, 830, 140]); title(axInput, 'Input');
    axHn = uiaxes(tabFilter, 'Position', [10, 240, 400, 180]); title(axHn, 'h[n]');
    axFR = uiaxes(tabFilter, 'Position', [420, 240, 420, 180]); title(axFR, 'TChart (FR h(x))');
    axTChart = uiaxes(tabFilter, 'Position', [10, 10, 400, 220]); title(axTChart, 'TChart (Detail Coefficients)');
    axJ = uiaxes(tabFilter, 'Position', [420, 10, 420, 220]); title(axJ, 'TChart (g[n] HPF)');
    axDetect = uiaxes(tabDetection, 'Position', [20, 20, 820, 580]); title(axDetect, 'TChart (Detection Pulses)');
    
    % 5. FUNGSI EKSEKUSI
    btnAction.ButtonPushedFcn = @(btn,event) runProcessing();
    
    function runProcessing()
        % -- A. LOAD DATA & SISTEM CADANGAN --
        ecg_signal = []; fs = 125;
        try
            data = readmatrix('C:\Users\talit\Documents\mitbih_test.csv'); 
            if ~isempty(data) && size(data, 1) >= 5 && size(data, 2) >= 187
                ecg_signal = reshape(data(1:5, 1:187)', 1, []);
            end
        catch
        end
        
        if isempty(ecg_signal)
            fs = 250; t = linspace(0, 4, 4 * fs);
            ecg_signal = 0.05 * sin(2 * pi * 1.5 * t); 
            for i = 1:5
                idx = round(i * 0.8 * fs);
                if idx < length(ecg_signal) - 40
                    ecg_signal(idx) = 1.2; ecg_signal(idx - 4) = -0.3; ecg_signal(idx + 6) = -0.4;
                    ecg_signal(idx - 15) = 0.2; ecg_signal(idx + 35) = 0.3;
                end
            end
        end
        
        % -- B. FILTER & DWT MANUAL (db4) --
        s2 = sqrt(2); s3 = sqrt(3); h = zeros(1, 4);
        h(1) = (1 + s3) / (4 * s2); h(2) = (3 + s3) / (4 * s2);
        h(3) = (3 - s3) / (4 * s2); h(4) = (1 - s3) / (4 * s2);
        g = zeros(1, 4);
        for i = 1:4, g(i) = (-1)^(i-1) * h(5 - i); end
        
        len = length(ecg_signal); half_len = floor(len / 2);
        detail = zeros(1, half_len);
        for i = 1:half_len
            for j = 1:4
                idx = 2 * i - (j - 1); 
                if idx > 0 && idx <= len, detail(i) = detail(i) + ecg_signal(idx) * g(j); end
            end
        end
        
        % -- C. DETEKSI DENGAN PARAMETER DINAMIS --
        w_QRS = in_T1.Value / 1000;   
        p_start_val = in_D1.Value / 1000; p_end_val = in_D2.Value / 1000;   
        t_start_val = in_D3.Value / 1000; t_end_val = in_D4.Value / 1000;   

        gate_qrs = zeros(1, len); gate_p = zeros(1, len); gate_t = zeros(1, len);
        threshold = mean(ecg_signal) + 1.2 * std(ecg_signal);
        r_peaks = [];
        for i = 2:len-1
            if ecg_signal(i) > threshold && ecg_signal(i) > ecg_signal(i-1) && ecg_signal(i) > ecg_signal(i+1)
                if isempty(r_peaks) || (i - r_peaks(end)) > (0.4 * fs)
                    r_peaks = [r_peaks, i];
                end
            end
        end
        
        for r = r_peaks
            gate_qrs(max(1, r - round(w_QRS * fs)) : min(len, r + round(w_QRS * fs))) = 1.0; 
            p_s = max(1, r - round(p_start_val * fs)); p_e = max(1, r - round(p_end_val * fs));
            if p_s < p_e, gate_p(p_s:p_e) = 0.7; end
            t_s = min(len, r + round(t_start_val * fs)); t_e = min(len, r + round(t_end_val * fs));
            if t_s < t_e, gate_t(t_s:t_e) = 0.5; end
        end
        
        % -- D. PLOTTING --
        plot(axInput, ecg_signal, 'Color', '#3b5998'); grid(axInput, 'on');
        bar(axHn, [-2, -1, 0, 1], h, 0.6, 'FaceColor', '#3b5998'); grid(axHn, 'on');
        plot(axFR, cumsum(h), 'Color', '#3b5998'); grid(axFR, 'on'); 
        plot(axTChart, detail, 'Color', '#ff7f0e'); grid(axTChart, 'on');
        bar(axJ, [-2, -1, 0, 1], g, 0.8, 'FaceColor', '#3b5998'); grid(axJ, 'on');
        
        plot(axDetect, ecg_signal, 'Color', '#3b5998', 'LineWidth', 1); hold(axDetect, 'on');
        stairs(axDetect, gate_qrs, 'Color', '#ff7f0e', 'LineWidth', 1.5);
        stairs(axDetect, gate_p, 'Color', '#2ca02c', 'LineWidth', 1.5);
        stairs(axDetect, gate_t, 'Color', '#d62728', 'LineWidth', 1.5); hold(axDetect, 'off');
        
        grid(axDetect, 'on'); ylim(axDetect, [-0.5 1.5]); xlim(axDetect, [0 len]);
        legend(axDetect, {'Sinyal EKG', 'QRS', 'P', 'T'}, 'Location', 'northeast');
        tabGroup.SelectedTab = tabDetection;
    end
end