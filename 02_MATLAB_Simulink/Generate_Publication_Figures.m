%% ========================================================================
%  Generate_Publication_Figures.m
%  Run after simulation, with the SimulationOutput object available as
%  "out" in the workspace.
%
%  IMPORTANT: set `scenario` below to match the run BEFORE each execution.
%  This keeps each scenario's figures/table in its own subfolder with
%  suffixed filenames, so re-running for a different test signal never
%  silently overwrites a previous scenario's output.
%  ========================================================================

clear S results

%% ---- 0. SCENARIO LABEL (EDIT THIS BEFORE EACH RUN) --------------------
scenario = 'Step';   % e.g. 'Step', 'Spiral', 'Spiral_Disturbance', 'ParamVariation'

outdir = fullfile(pwd, 'Results', ['figures_export_' scenario]);
if ~exist(outdir, 'dir'), mkdir(outdir); end

%% ---- 1. CANONICAL TIME VECTOR --------------------------------------
tt = out.t(:);

N = numel(tt);

%% ---- 2. RESHAPE ALL SIGNALS TO [N x 3] -------------------------------
ctrl = {'smc','stsmc','astsmc'};
sig3 = {'e','q','s','tau','v'};

S = struct();
missing = {};
for i = 1:numel(ctrl)
    c = ctrl{i};
    for j = 1:numel(sig3)
        f = [sig3{j} '_' c];
        try, S.(f) = squeeze(out.(f))'; catch, missing{end+1}=f; end
    end
    pf = ['p_' c];
    try, S.(pf) = out.(pf); catch, missing{end+1}=pf; end
end
extras = {'qd','pd','k1_astsmc','k2_astsmc','dist_signal'};
for i = 1:numel(extras)
    f = extras{i};
    try, S.(f) = squeeze(out.(f))'; catch, missing{end+1}=f; end
end
if ~isempty(missing)
    warning('Signals not found, skipped:\n%s', strjoin(missing, ', '));
end

%% ---- 3. Reusable figure settings --------------------------------
sty.smc     = struct('color',[228 26 28]/255,  'line','--','lw',1.8,'name','SMC');
sty.stsmc   = struct('color',[55 126 184]/255, 'line','-.','lw',1.8,'name','STSMC');
sty.astsmc  = struct('color',[0 0 0],           'line','-', 'lw',2.0,'name','ASTSMC');
sty.desired = struct('color',[130 130 130]/255,'line','-', 'lw',2.3,'name','Desired');

jointLabelQ = {'\theta_1 (rad)','\theta_2 (rad)','d_3 (m)'};
jointLabelE = {'Tracking Error \theta_1 (rad)','Tracking Error \theta_2 (rad)','Tracking Error d_3 (m)'};
jointLabelS = {'Sliding Surface s_1 (\theta_1)','Sliding Surface s_2 (\theta_2)','Sliding Surface s_3 (d_3)'};
jointLabelT = {'\tau_1 (N\cdotm)','\tau_2 (N\cdotm)','F_3 (N)'};

xt = 0:2:ceil(tt(end));
lbl = {'(a)','(b)','(c)'};
FIGSZ = [2 2 18 15];   % cm

%% ======================= FIG: JOINT TRACKING ===========================
fig1 = figure('Units','centimeters','Position',FIGSZ,'Color','w');
tl = tiledlayout(3,1,'TileSpacing','compact','Padding','compact');
for j = 1:3
    ax = nexttile; hold(ax,'on');
    plot(ax, tt, S.qd(:,j), 'Color',sty.desired.color,'LineStyle',sty.desired.line,'LineWidth',sty.desired.lw);
    for i = 1:numel(ctrl)
        c = ctrl{i};
        plot(ax, tt, S.(['q_' c])(:,j), 'Color',sty.(c).color,'LineStyle',sty.(c).line,'LineWidth',sty.(c).lw);
    end
    ylabel(ax, jointLabelQ{j}, 'FontSize',12);
    xticks(ax, xt);
    applyPubStyle(ax); addPanelLabel(ax, lbl{j});
    if j==3, xlabel(ax,'Time (s)','FontSize',12); end
end
lg = legend(ax, {sty.desired.name, sty.smc.name, sty.stsmc.name, sty.astsmc.name}, ...
    'Orientation','horizontal','NumColumns',4,'Box','off','FontSize',10);
lg.Layout.Tile = 'north';
exportPDF(fig1, ['JointTracking_' scenario], outdir);

%% ======================= FIG: TRACKING ERROR ============================
fig2 = figure('Units','centimeters','Position',FIGSZ,'Color','w');
tl = tiledlayout(3,1,'TileSpacing','compact','Padding','compact');
for j = 1:3
    ax = nexttile; hold(ax,'on');
    yline(ax, 0, ':', 'Color',[0.6 0.6 0.6],'LineWidth',1);
    for i = 1:numel(ctrl)
        c = ctrl{i};
        plot(ax, tt, S.(['e_' c])(:,j), 'Color',sty.(c).color,'LineStyle',sty.(c).line,'LineWidth',sty.(c).lw);
    end
    ylabel(ax, jointLabelE{j}, 'FontSize',12);
    xticks(ax, xt);
    applyPubStyle(ax); addPanelLabel(ax, lbl{j});
    if j==3, xlabel(ax,'Time (s)','FontSize',12); end
end
lg = legend(ax, {sty.smc.name, sty.stsmc.name, sty.astsmc.name}, ...
    'Orientation','horizontal','NumColumns',3,'Box','off','FontSize',10);
lg.Layout.Tile = 'north';
exportPDF(fig2, ['TrackingError_' scenario], outdir);

%% ======================= FIG: SLIDING SURFACE ============================
fig3 = figure('Units','centimeters','Position',FIGSZ,'Color','w');
tl = tiledlayout(3,1,'TileSpacing','compact','Padding','compact');
for j = 1:3
    ax = nexttile; hold(ax,'on');
    yline(ax, 0, ':', 'Color',[0.6 0.6 0.6],'LineWidth',1);
    for i = 1:numel(ctrl)
        c = ctrl{i};
        plot(ax, tt, S.(['s_' c])(:,j), 'Color',sty.(c).color,'LineStyle',sty.(c).line,'LineWidth',sty.(c).lw);
    end
    ylabel(ax, jointLabelS{j}, 'FontSize',12);
    xticks(ax, xt);
    applyPubStyle(ax); addPanelLabel(ax, lbl{j});
    if j==3, xlabel(ax,'Time (s)','FontSize',12); end
end
lg = legend(ax, {sty.smc.name, sty.stsmc.name, sty.astsmc.name}, ...
    'Orientation','horizontal','NumColumns',3,'Box','off','FontSize',10);
lg.Layout.Tile = 'north';
exportPDF(fig3, ['SlidingSurface_' scenario], outdir);

%% ======================= FIG: TORQUE ======================================
fig4 = figure('Units','centimeters','Position',FIGSZ,'Color','w');
tl = tiledlayout(3,1,'TileSpacing','compact','Padding','compact');
for j = 1:3
    ax = nexttile; hold(ax,'on');
    for i = 1:numel(ctrl)
        c = ctrl{i};
        plot(ax, tt, S.(['tau_' c])(:,j), 'Color',sty.(c).color,'LineStyle','-','LineWidth',sty.(c).lw);
    end
    ylabel(ax, jointLabelT{j}, 'FontSize',12);
    xticks(ax, xt);
    applyPubStyle(ax); addPanelLabel(ax, lbl{j});
    if j==3, xlabel(ax,'Time (s)','FontSize',12); end
end
lg = legend(ax, {sty.smc.name, sty.stsmc.name, sty.astsmc.name}, ...
    'Orientation','horizontal','NumColumns',3,'Box','off','FontSize',10);
lg.Layout.Tile = 'north';
exportPDF(fig4, ['Torque_' scenario], outdir);

%% ======================= FIG: ADAPTIVE GAIN vs DISTURBANCE ================
fig5 = figure('Units','centimeters','Position',[2 2 18 11],'Color','w');
tl = tiledlayout(3,1,'TileSpacing','compact','Padding','compact');
distColors = [0.9 0.6 0.1; 0.1 0.6 0.3; 0.5 0.2 0.7];
for j = 1:3
    ax = nexttile;
    yyaxis(ax,'left');
    plot(ax, tt, S.dist_signal(:,j), '--k', 'LineWidth',1.5);
    ylabel(ax, sprintf('\\Delta_%d', j), 'FontSize',12);
    yyaxis(ax,'right');
    plot(ax, tt, S.k1_astsmc(:,j), 'Color', distColors(j,:), 'LineWidth',2.0);
    ylabel(ax, sprintf('k_{1,%d}', j), 'FontSize',12);
    xticks(ax, xt);
    applyPubStyle(ax); addPanelLabel(ax, lbl{j});
    if j==3, xlabel(ax,'Time (s)','FontSize',12); end
    if j==1
        legend(ax, {'Disturbance \Delta', 'Adaptive gain k_1'}, ...
            'Orientation','horizontal','Location','northoutside','Box','off','FontSize',10);
    end
end
exportPDF(fig5, ['AdaptiveGain_' scenario], outdir);

%% ======================= FIG: CARTESIAN TRACKING ==========================

fig6 = figure('Units','centimeters','Position',FIGSZ,'Color','w');
tl = tiledlayout(3,1,'TileSpacing','compact','Padding','compact');
cartLabel = {'X (m)','Y (m)','d_3 (m)'};
for j = 1:3
    ax = nexttile; hold(ax,'on');
    if j <= 2
        desiredSig = S.pd(:,j);
    else
        desiredSig = S.qd(:,3);   % joint-level d3d, not pd(:,3)
    end
    plot(ax, tt, desiredSig, 'Color',sty.desired.color,'LineStyle',sty.desired.line,'LineWidth',sty.desired.lw);
    for i = 1:numel(ctrl)
        c = ctrl{i};
        if j <= 2
            actualSig = S.(['p_' c])(:,j);
        else
            actualSig = S.(['q_' c])(:,3);   % joint-level d3, not p_*(:,3)=Z
        end
        plot(ax, tt, actualSig, 'Color',sty.(c).color,'LineStyle',sty.(c).line,'LineWidth',sty.(c).lw);
    end
    ylabel(ax, cartLabel{j}, 'FontSize',12);
    xticks(ax, xt);
    applyPubStyle(ax); addPanelLabel(ax, lbl{j});
    if j==3, xlabel(ax,'Time (s)','FontSize',12); end
end
lg = legend(ax, {sty.desired.name, sty.smc.name, sty.stsmc.name, sty.astsmc.name}, ...
    'Orientation','horizontal','NumColumns',4,'Box','off','FontSize',10);
lg.Layout.Tile = 'north';
exportPDF(fig6, ['CartesianTracking_' scenario], outdir);

%% ======================= FIG: XY SPIRAL PATH ================================
fig7 = figure('Units','centimeters','Position',[2 2 13 13],'Color','w');
ax = axes; hold(ax,'on'); axis(ax,'equal');
plot(ax, S.pd(:,1), S.pd(:,2), 'Color',sty.desired.color,'LineStyle',sty.desired.line,'LineWidth',sty.desired.lw);
for i = 1:numel(ctrl)
    c = ctrl{i};
    plot(ax, S.(['p_' c])(:,1), S.(['p_' c])(:,2), 'Color',sty.(c).color,'LineStyle',sty.(c).line,'LineWidth',sty.(c).lw);
end
plot(ax, S.pd(1,1), S.pd(1,2), 'o', 'MarkerSize',8, 'MarkerFaceColor','g','MarkerEdgeColor','k');
plot(ax, S.pd(end,1), S.pd(end,2), 's', 'MarkerSize',8, 'MarkerFaceColor','r','MarkerEdgeColor','k');
xlabel(ax,'X (m)','FontSize',12); ylabel(ax,'Y (m)','FontSize',12);
applyPubStyle(ax);
legend(ax, {sty.desired.name, sty.smc.name, sty.stsmc.name, sty.astsmc.name, 'Start','End'}, ...
    'Orientation','horizontal','Location','northoutside','NumColumns',3,'Box','off','FontSize',10);
exportPDF(fig7, ['SpiralTracking_' scenario], outdir);

%% ======================= TABLE 1: ITAE + CONTROL EFFORT =====================
results = table();
for i = 1:numel(ctrl)
    c = ctrl{i};
    e   = S.(['e_' c]);
    tau = S.(['tau_' c]);
    ITAE = zeros(1,3); tauL2 = zeros(1,3);
    for j = 1:3
        ITAE(j)  = trapz(tt, tt .* abs(e(:,j)));
        tauL2(j) = sqrt(trapz(tt, tau(:,j).^2));
    end
    ITAE_total = sum(ITAE);
    tauRMS = sqrt(trapz(tt, sum(tau.^2,2)) / (tt(end)-tt(1)));
    row = table({sty.(c).name}, ITAE(1), ITAE(2), ITAE(3), ITAE_total, ...
                 tauL2(1), tauL2(2), tauL2(3), tauRMS, ...
        'VariableNames', {'Controller','ITAE_1','ITAE_2','ITAE_3','ITAE_total', ...
                           'tauL2_1','tauL2_2','tauL2_3','tauRMS'});
    results = [results; row];
end
disp(results);
writetable(results, fullfile(outdir, ['Table1_ITAE_ControlEffort_' scenario '.csv']));

fprintf('\nScenario "%s": all figures (PDF) and table exported to:\n%s\n', scenario, outdir);

%% ======================= LOCAL FUNCTIONS (must be at end of script) =====
function applyPubStyle(ax)
    set(ax,'FontName','Times New Roman','FontSize',11,'LineWidth',1.1, ...
        'TickDir','out','Box','on');
    grid(ax,'off');
end

function addPanelLabel(ax, lbl)
    text(ax, 0.02, 0.92, lbl, 'Units','normalized', ...
        'FontWeight','bold','FontName','Times New Roman','FontSize',11);
end

function exportPDF(fig, name, outdir)
    exportgraphics(fig, fullfile(outdir, [name '.pdf']), 'ContentType','vector');
    exportgraphics(fig, fullfile(outdir,[name '.png']), 'Resolution',600)
end