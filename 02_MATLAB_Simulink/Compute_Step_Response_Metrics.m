%% ========================================================================
%  Compute_Step_Response_Metrics.m
%  Rise time, overshoot, and settling time for the Nominal Step scenario,
%  per joint and per controller, computed directly from the workspace
%  SimulationOutput object "out" (must be the STEP scenario run).
%  ========================================================================

ctrl = {'smc','stsmc','astsmc'};
ctrlName = {'SMC','STSMC','ASTSMC'};
jointName = {'theta_1','theta_2','d_3'};
settle_pct = 0.02;   % +/-2% settling band (standard convention)

tt = out.t(:);

% Desired signal is constant throughout a step test (Xd=Xf for all t>0),
% so qd(1,:) == qd(end,:) -- use it only as the TARGET (yf).
% The step's actual STARTING point is the plant's initial condition,
% which must be read from each controller's own response q_*(1,:),
% not from qd -- this was the bug that produced all-NaN results.
qd = squeeze(out.qd)';   % [N x 3]
yf_common = qd(1,:);      % target per joint (constant for all t, all controllers)

fprintf('%-8s %-8s %10s %10s %10s %10s\n', 'Ctrl','Joint','Rise(s)','Settle(s)','Peak(s)','OS(%)');
fprintf('%s\n', repmat('-',1,60));

results = struct();

for i = 1:numel(ctrl)
    c = ctrl{i};
    q = squeeze(out.(['q_' c]))';   % [N x 3]

    for j = 1:3
        y = q(:,j);
        y0j = y(1);            % actual initial response (from THIS controller's own trace)
        yfj = yf_common(j);    % constant target
        delta = yfj - y0j;

        if abs(delta) < 1e-9
            % No actual step on this joint -- skip metric computation
            Tr = NaN; Ts = NaN; Tp = NaN; OS = NaN;
        else
            %% Rise time: 10% to 90% of step size
            y10 = y0j + 0.10*delta;
            y90 = y0j + 0.90*delta;
            if delta > 0
                i10 = find(y >= y10, 1, 'first');
                i90 = find(y >= y90, 1, 'first');
            else
                i10 = find(y <= y10, 1, 'first');
                i90 = find(y <= y90, 1, 'first');
            end
            if isempty(i10) || isempty(i90)
                Tr = NaN;
            else
                Tr = tt(i90) - tt(i10);
            end

            %% Settling time: last time response leaves +/-settle_pct band
            band = settle_pct * abs(delta);
            outside = abs(y - yfj) > band;
            idxLastOutside = find(outside, 1, 'last');
            if isempty(idxLastOutside)
                Ts = 0;
            else
                Ts = tt(idxLastOutside);
            end

            %% Peak overshoot (percent of step size)
            if delta > 0
                [ypk, ipk] = max(y);
            else
                [ypk, ipk] = min(y);
            end
            Tp = tt(ipk);
            OS = max(0, (ypk - yfj) / abs(delta) * 100 * sign(delta));
        end

        fprintf('%-8s %-8s %10.4f %10.4f %10.4f %10.2f\n', ...
            ctrlName{i}, jointName{j}, Tr, Ts, Tp, OS);

        results.(c).(jointName{j}) = struct('RiseTime',Tr,'SettlingTime',Ts,'PeakTime',Tp,'Overshoot',OS);
    end
end

% Save to a table for easy export/citation in the manuscript
rows = {};
for i = 1:numel(ctrl)
    c = ctrl{i};
    for j = 1:3
        r = results.(c).(jointName{j});
        rows(end+1,:) = {ctrlName{i}, jointName{j}, r.RiseTime, r.SettlingTime, r.PeakTime, r.Overshoot}; %#ok<SAGROW>
    end
end
T = cell2table(rows, 'VariableNames', {'Controller','Joint','RiseTime_s','SettlingTime_s','PeakTime_s','Overshoot_pct'});
disp(T);
writetable(T, 'StepResponseMetrics.csv');
fprintf('\nSaved to StepResponseMetrics.csv\n');