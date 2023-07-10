function selfGrootDefault(theme)
if nargin<1
    theme=0;
end

try
set(groot,'defaultLineLineWidth',2)
set(groot,'defaultAxesFontName','Arial')
set(groot,'defaultAxesColorOrder',[102,194,165; ...
    252,140,98; ...
    142,160,204; ...
    231,138,195; ...
    166,217,83; ...
    255,217,48; ...
    229,196,148; ...
    179,179,179]./255)
% set(groot,'defaultAxesProjection','perspective')
set(groot,'defaultSurfaceEdgeColor',[1,1,1].*.7);
set(groot,'defaultSurfaceEdgeAlpha',.5);


CM=[127	0	255	126	0	254	125	1	254	125	2	254	124	3	254	123	5	254	122	6	254	121	7	254	121	8	254	120	10	254	119	11	254	118	12	254	117	13	254	117	14	254	116	16	254	115	17	254	114	18	254	113	19	254	113	20	254	112	22	254	111	24	254	110	25	254	109	26	254	108	28	254	108	29	254	107	30	254	106	31	254	105	32	254	104	34	254	104	35	254	103	36	254	102	37	254	101	38	254	100	40	254	100	41	254	99	42	254	98	43	253	97	45	253	96	46	253	96	47	253	95	48	253	94	50	253	93	51	253	92	53	253	92	54	253	91	55	253	90	56	253	89	58	253	88	59	253	87	60	253	87	61	253	86	62	252	85	64	252	84	65	252	83	66	252	83	67	252	82	69	252	81	70	252	80	71	252	79	72	252	79	73	252	78	75	251	77	76	251	76	77	251	75	78	251	75	79	251	74	81	251	73	82	251	72	83	251	71	84	251	70	86	250	70	87	250	69	88	250	68	89	250	67	90	250	66	92	250	66	93	250	65	94	250	64	95	250
63	96	250	62	97	249	62	98	249	61	99	249	60	100	249	59	102	249	58	103	249	58	104	249	57	105	249	56	106	248	55	108	248	54	109	248	53	110	248	53	111	248	52	112	248	51	114	248	50	115	247	49	116	247	49	116	247	48	118	247	47	119	247	46	120	246	45	121	246	45	122	246	44	124	246	43	125	246	42	126	246	41	127	246	41	127	246	40	129	245	39	130	245	38	131	245	37	132	245	36	134	244	36	134	244	35	135	244	34	136	244	33	137	244	32	139	243	32	140	243	31	141	243	30	142	243	29	143	243	28	144	243	28	145	243	27	146	243	26	147	242	25	148	242	24	149	242	24	150	242	23	151	242	22	152	241	21	153	241	20	154	241	20	155	241	19	156	241	18	157	240	17	158	240	16	159	239	15	160	239	15	161	239	14	162	239	13	163	239	12	164	238	11	165	238	11	166	238	10	167	238	9	168	238	8	169	237	7	170	237	7	170	237	6	172	237	5	173	237	4	174	236	3	175	236	3	175	236	2	176	236	1	177	236	0	178	235
0	179	235	0	180	234	0	181	234	1	182	234	2	183	234	3	184	234	4	185	233	4	185	233	5	186	233	6	187	232	7	188	232	8	189	232	8	189	232	9	190	232	10	191	231	11	192	231	12	193	230	12	193	230	13	194	230	14	195	230	15	196	230	16	197	229	17	198	229	17	198	229	18	199	228	19	200	228	20	201	228	21	202	228	21	202	228	22	203	227	23	204	227	24	205	226	25	206	226	25	206	226	26	207	226	27	208	226	28	209	225	29	209	225	29	209	225	30	210	224	31	211	224	32	212	223	33	213	223	33	213	223	34	214	223	35	214	223	36	215	222	37	216	222	38	217	221	38	217	221	39	218	221	40	219	220	41	219	220	42	220	220	42	220	220	43	221	220	44	222	219	45	222	219	46	223	218	46	223	218	47	224	218	48	225	217	49	225	217	50	226	216	50	226	216	51	227	216	52	228	215	53	228	215	54	229	215	55	229	215	55	229	215	56	230	214	57	231	214	58	232	213	59	232	213	59	232	213	60	233	212	61	233	212	62	234	211
63	235	211	63	235	211	64	236	210	65	236	210	66	237	209	67	237	209	67	237	209	68	238	209	69	238	209	70	239	208	71	239	208	72	240	207	72	240	207	73	240	207	74	241	206	75	241	206	76	242	205	76	242	205	77	242	205	78	243	204	79	243	204	80	244	203	80	244	203	81	244	203	82	245	202	83	245	202	84	246	201	84	246	201	85	246	201	86	246	200	87	246	200	88	247	199	88	247	199	89	247	199	90	248	198	91	248	198	92	249	197	93	249	197	93	249	197	94	249	196	95	249	196	96	250	195	97	250	195	97	250	195	98	250	194	99	250	194	100	251	193	101	251	193	101	251	193	102	251	192	103	251	192	104	252	191	105	252	191	105	252	191	106	252	190	107	252	190	108	253	189	109	253	189	110	253	188	110	253	188	111	253	188	112	253	187	113	253	187	114	254	186	114	254	186	115	254	186	116	254	185	117	254	185	118	254	184	118	254	184	119	254	184	120	254	183	121	254	183	122	254	182	122	254	182	123	254	181	124	254	180	125	254	180	126	254	179
127	254	179	127	254	179	128	254	178	129	254	178	130	254	177	131	254	177	131	254	177	132	254	176	133	254	176	134	254	175	135	254	175	135	254	175	136	254	174	137	254	174	138	254	173	139	254	172	139	254	172	140	253	171	141	253	171	142	253	170	143	253	170	143	253	170	144	253	169	145	253	169	146	252	168	147	252	168	148	252	167	148	252	167	149	252	167	150	251	166	151	251	165	152	251	164	152	251	164	153	251	164	154	250	163	155	250	163	156	250	162	156	250	162	157	250	162	158	249	161	159	249	161	160	249	160	160	249	160	161	249	159	162	248	158	163	248	158	164	247	157	165	247	157	165	247	157	166	246	156	167	246	156	168	246	155	169	246	154	169	246	154	170	245	153	171	245	153	172	244	152	173	244	152	173	244	152	174	243	151	175	243	151	176	242	150	177	242	149	177	242	149	178	241	148	179	241	148	180	240	147	181	240	147	182	239	146	182	239	146	183	239	146	184	238	145	185	238	144	186	237	143	186	237	143	187	237	143	188	236	142	189	236	142	190	235	141
190	235	141	191	234	140	192	233	139	193	233	139	194	232	138	194	232	138	195	232	138	196	231	137	197	230	136	198	229	135	199	229	135	199	229	135	200	228	134	201	228	134	202	227	133	203	226	132	203	226	132	204	225	131	205	225	131	206	224	130	207	223	130	207	223	130	208	222	129	209	222	128	210	221	127	211	220	127	211	220	127	212	219	126	213	219	126	214	218	125	215	217	124	215	217	124	216	216	123	217	215	123	218	214	122	219	214	122	220	213	121	220	213	121	221	212	120	222	211	119	223	210	119	224	209	118	224	209	118	225	209	117	226	208	116	227	207	116	228	206	115	228	206	115	229	205	115	230	204	114	231	203	113	232	202	112	232	202	112	233	201	112	234	200	111	235	199	110	236	198	109	237	197	109	237	197	109	238	196	108	239	195	108	240	194	107	241	193	106	241	193	106	242	192	105	243	191	105	244	190	104	245	189	103	245	189	103	246	188	102	247	187	102	248	186	101	249	185	100	249	185	100	250	184	99	251	183	99	252	182	98	253	181	97	253	180	97
254	179	96	254	178	96	255	177	95	255	176	95	255	175	94	255	175	94	255	174	93	255	173	92	255	172	92	255	170	91	255	170	91	255	169	90	255	168	89	255	167	89	255	166	88	255	165	88	255	164	87	255	163	86	255	162	86	255	161	85	255	160	85	255	159	84	255	158	83	255	157	83	255	156	82	255	155	81	255	154	81	255	153	80	255	152	80	255	151	79	255	150	78	255	149	78	255	148	77	255	147	77	255	146	76	255	145	75	255	144	75	255	143	74	255	142	74	255	141	73	255	140	72	255	139	72	255	137	71	255	136	71	255	135	70	255	134	69	255	133	68	255	132	68	255	131	68	255	130	67	255	129	66	255	127	65	255	127	65	255	126	65	255	125	64	255	124	63	255	122	62	255	121	62	255	120	62	255	119	61	255	117	60	255	116	59	255	116	59	255	115	59	255	114	58	255	112	57	255	111	56	255	110	56	255	109	56	255	108	55	255	106	54	255	105	53	255	104	53	255	103	53	255	102	52	255	100	51	255	99	50	255	98	49	255	97	49
255	96	48	255	95	48	255	94	47	255	93	46	255	92	46	255	90	45	255	89	45	255	88	44	255	87	43	255	86	43	255	84	42	255	83	42	255	82	41	255	81	40	255	79	39	255	78	39	255	77	39	255	76	38	255	75	37	255	73	36	255	72	36	255	71	36	255	70	35	255	69	34	255	67	33	255	66	33	255	65	32	255	64	31	255	62	31	255	61	30	255	60	30	255	59	29	255	58	28	255	56	28	255	55	27	255	54	26	255	53	26	255	51	25	255	50	25	255	48	24	255	47	23	255	46	23	255	44	22	255	43	21	255	42	20	255	41	20	255	40	20	255	38	19	255	37	18	255	36	17	255	35	17	255	34	17	255	32	16	255	31	15	255	30	14	255	29	14	255	28	14	255	26	13	255	25	12	255	24	11	255	22	10	255	20	9	255	19	9	255	18	9	255	17	8	255	16	7	255	14	6	255	13	6	255	12	6	255	11	5	255	10	4	255	8	3	255	7	3	255	6	3	255	5	2	255	3	1	255	2	0	255	1	0	255	0	0]./255;
set(groot,'defaultFigureColormap',reshape(CM',3,[])');
set(groot,'defaultPatchLineWidth',2);
set(groot,'defaultPatchFaceAlpha',.5);
set(groot,'defaultAreaFaceAlpha',.6)
set(groot,'defaultAreaLineWidth',1.5)
set(groot,'defaultAreaEdgeColor',[.2,.2,.2])
set(groot,'defaultBarLineWidth',1.5)
set(groot,'defaultBarFaceAlpha',.8)
set(groot,'defaultStemLineWidth',1.2)
catch
end


oriDefault()
switch theme
    case {0,'origin'} 
        set(groot,'defaultLineLineWidth',0.5)
        set(groot,'defaultAxesColorOrder',[    0    0.4470    0.7410;...
            0.8500    0.3250    0.0980;...
            0.9290    0.6940    0.1250;...
            0.4940    0.1840    0.5560;...
            0.4660    0.6740    0.1880;...
            0.3010    0.7450    0.9330;...
            0.6350    0.0780    0.1840])
        set(groot,'defaultLegendTextColor',[0,0,0])
        set(groot,'defaultAxesProjection','orthographic')
        set(groot,'defaultFigureColormap',parula)
        set(groot,'defaultSurfaceEdgeColor',[0,0,0]);
        set(groot,'defaultSurfaceEdgeAlpha',1);
        set(groot,'defaultPatchLineWidth',.5);
        set(groot,'defaultPatchFaceAlpha',1);
        set(groot,'defaultAxesFontSize',10)
        set(groot,'defaultAreaFaceAlpha',1)
        set(groot,'defaultAreaLineWidth',.5)
        set(groot,'defaultAreaEdgeColor',[0,0,0])
        set(groot,'defaultBarLineWidth',.5)
        set(groot,'defaultBarFaceAlpha',1)
        set(groot,'defaultStemLineWidth',.5)
    case {1,'gbase'}
        set(groot,'defaultAxesLineWidth',1.2)
        set(groot,'defaultAxesXMinorTick','on')
        set(groot,'defaultAxesYMinorTick','on')
        set(groot,'defaultAxesZMinorTick','on')
        set(groot,'defaultAxesGridLineStyle','-.')
        set(groot,'defaultAxesXColor',[1,1,1].*.3)
        set(groot,'defaultAxesYColor',[1,1,1].*.3)
        set(groot,'defaultAxesZColor',[1,1,1].*.3)
        set(groot,'defaultAxesXGrid','on')
        set(groot,'defaultAxesYGrid','on')
        set(groot,'defaultAxesZGrid','on')
        set(groot,'defaultAxesTickDir','in','defaultAxesTickDirMode','auto')
        set(groot,'defaultLegendTextColor',[0,0,0])
    case {2,'gbase2'}
        set(groot,'defaultAxesLineWidth',1.2)
        set(groot,'defaultAxesXMinorTick','on')
        set(groot,'defaultAxesYMinorTick','on')
        set(groot,'defaultAxesZMinorTick','on')
        set(groot,'defaultAxesGridLineStyle','-.')
        set(groot,'defaultAxesXColor',[1,1,1].*.3)
        set(groot,'defaultAxesYColor',[1,1,1].*.3)
        set(groot,'defaultAxesZColor',[1,1,1].*.3)
        set(groot,'defaultAxesXGrid','on')
        set(groot,'defaultAxesYGrid','on')
        set(groot,'defaultAxesZGrid','on')
        set(groot,'defaultAxesColor',[249,250,245]./255)
        set(groot,'defaultAxesTickDir','in','defaultAxesTickDirMode','auto')
        set(groot,'defaultLegendTextColor',[0,0,0])
    case {3,'dark'}
        set(groot,'defaultAxesColor',[0,0,0])
        set(groot,'defaultFigureColor',[0,0,0])
        set(groot,'defaultAxesXMinorTick','on')
        set(groot,'defaultAxesYMinorTick','on')
        set(groot,'defaultAxesZMinorTick','on')
        set(groot,'defaultAxesXGrid','on')
        set(groot,'defaultAxesYGrid','on')
        set(groot,'defaultAxesZGrid','on')
        set(groot,'defaultAxesXMinorGrid','on','defaultAxesXMinorGridMode','manual')
        set(groot,'defaultAxesYMinorGrid','on','defaultAxesYMinorGridMode','manual')
        set(groot,'defaultAxesZMinorGrid','on','defaultAxesZMinorGridMode','manual')
        set(groot,'defaultFigureInvertHardCopy','off')
        set(groot,'defaultAxesGridColor',[0.2353 0.4235 0.4745])
        set(groot,'defaultAxesMinorGridColor',[0.1569 0.2039 0.1882])
        set(groot,'defaultAxesXColor',[1,1,1])
        set(groot,'defaultAxesYColor',[1,1,1])
        set(groot,'defaultAxesZColor',[1,1,1])
        set(groot,'defaultAxesLineWidth',1.2)
        set(groot,'defaultAxesGridAlpha',.8)
        set(groot,'defaultAxesMinorGridAlpha',0.7) 
        set(groot,'defaultAxesTickDir','in','defaultAxesTickDirMode','auto')
        set(groot,'defaultLegendTextColor',[1,1,1])
    case {4,'dark2'}
        set(groot,'defaultAxesColor',[2,34,57]./255)
        set(groot,'defaultFigureColor',[2,34,57]./255)
        set(groot,'defaultFigureInvertHardCopy','off')
        set(groot,'defaultAxesXColor',[144,164,178]./255)
        set(groot,'defaultAxesYColor',[144,164,178]./255)
        set(groot,'defaultAxesZColor',[144,164,178]./255)
        set(groot,'defaultAxesLineWidth',1.2)
        set(groot,'defaultAxesXGrid','on')
        set(groot,'defaultAxesYGrid','on')
        set(groot,'defaultAxesZGrid','on')
        set(groot,'defaultAxesGridAlpha',.2)
        set(groot,'defaultAxesGridColor',[144,164,178]./255)
        set(groot,'defaultAxesXMinorTick','on')
        set(groot,'defaultAxesYMinorTick','on')
        set(groot,'defaultAxesZMinorTick','on')
        set(groot,'defaultAxesGridLineStyle','-.')
        set(groot,'defaultAxesTickDir','in','defaultAxesTickDirMode','auto')
        set(groot,'defaultLegendTextColor',[1,1,1])
    case {5,'ggray2'}
        set(groot,'defaultAxesColor',[234,234,242]./255)
        set(groot,'defaultFigureColor',[1,1,1])
        set(groot,'defaultAxesTickDir','out','defaultAxesTickDirMode','manual')
        set(groot,'defaultAxesXGrid','on')
        set(groot,'defaultAxesYGrid','on')
        set(groot,'defaultAxesZGrid','on')
        set(groot,'defaultAxesGridColor',[1,1,1])
        set(groot,'defaultAxesGridAlpha',1)
        set(groot,'defaultAxesLineWidth',1.2)
        set(groot,'defaultAxesXColor',[1,1,1].*.33)
        set(groot,'defaultAxesYColor',[1,1,1].*.33)
        set(groot,'defaultAxesZColor',[1,1,1].*.33)
        set(groot,'defaultAxesTickLength',[.005,.025])
        set(groot,'defaultLegendTextColor',[0,0,0])
        set(groot,'defaultAxesBox','off')
    case {6,'economist'}
        set(groot,'defaultAxesColor',[0.8400 0.8900 0.9200])
        set(groot,'defaultFigureColor',[0.8400 0.8900 0.9200])
        set(groot,'defaultFigureInvertHardCopy','off')
        set(groot,'defaultAxesBox','off')
        set(groot,'defaultAxesXGrid','off')
        set(groot,'defaultAxesYGrid','on')
        set(groot,'defaultAxesZGrid','on')
        set(groot,'defaultAxesGridColor',[1,1,1])
        set(groot,'defaultAxesGridAlpha',1)
        set(groot,'defaultAxesLineWidth',1.2)
        set(groot,'defaultAxesXColor',[1,1,1].*.33)
        set(groot,'defaultAxesYColor',[1,1,1].*.33)
        set(groot,'defaultAxesZColor',[1,1,1].*.33)
        set(groot,'defaultAxesTickLength',[.005,.025])
    case {7,'wsj'}
        set(groot,'defaultAxesColor',[0.9700 0.9500 0.8900])
        set(groot,'defaultFigureColor',[0.9700 0.9500 0.8900])
        set(groot,'defaultFigureInvertHardCopy','off')
        set(groot,'defaultAxesBox','off')
        set(groot,'defaultAxesXGrid','off')
        set(groot,'defaultAxesYGrid','on')
        set(groot,'defaultAxesZGrid','on')
        set(groot,'defaultAxesLineWidth',1)
        set(groot,'defaultAxesGridAlpha',1)
        set(groot,'defaultAxesTickLength',[.005,.025])
        set(groot,'defaultAxesGridLineStyle',':')
end
    function oriDefault(~,~)
        set(groot,'defaultAxesLineWidth',0.5)
        set(groot,'defaultAxesXMinorTick','off')
        set(groot,'defaultAxesYMinorTick','off')
        set(groot,'defaultAxesZMinorTick','off')
        set(groot,'defaultAxesXMinorGrid','off','defaultAxesXMinorGridMode','auto')
        set(groot,'defaultAxesYMinorGrid','off','defaultAxesYMinorGridMode','auto')
        set(groot,'defaultAxesZMinorGrid','off','defaultAxesZMinorGridMode','auto')
        set(groot,'defaultAxesGridLineStyle','-')
        set(groot,'defaultAxesGridColor',[1,1,1].*.15)
        set(groot,'defaultAxesMinorGridColor',[1,1,1].*.1)
        set(groot,'defaultAxesXColor',[1,1,1].*.15)
        set(groot,'defaultAxesYColor',[1,1,1].*.15)
        set(groot,'defaultAxesZColor',[1,1,1].*.15)
        set(groot,'defaultAxesGridAlpha',.15)
        set(groot,'defaultAxesMinorGridAlpha',.25)
        set(groot,'defaultAxesFontName','Helvetica')
        set(groot,'defaultAxesXGrid','off')
        set(groot,'defaultAxesYGrid','off')
        set(groot,'defaultAxesColor',[1,1,1])
        set(groot,'defaultFigureColor',[1,1,1].*.94)
        set(groot,'defaultAxesBox','off')
        set(groot,'defaultFigureInvertHardCopy','on')
        set(groot,'defaultAxesTickDir','in','defaultAxesTickDirMode','auto')
        set(groot,'defaultAxesTickLength',[.01,.025]) 
        
    end
end