using SymPy
N = 15
b = [symbols("b_$i", real=true) for i in 1:N]

# order 2
h = [1//2, 1, 1, 1]
H = Diagonal(h)

s = [-3//2, 2, -1//2, 0]

m1 = [(b[1]+b[2])/2, -(b[1]+b[2])/2, 0, 0]
m2 = [-(b[1]+b[2])/2, b[1]/2+b[2]+b[3]/2, -(b[2]+b[3])/2, 0]
m3 = [0, -(b[2]+b[3])/2, b[2]/2+b[3]+b[4]/2, -(b[3]+b[4])/2]
m4 = [0, 0, -(b[3]+b[4])/2, b[3]/2+b[4]+b[5]/2]
M = hcat(m1, m2, m3, m4)'

S = zeros(M)
S[1,:] = s

D2 = H \ (-M - b[1]*S)


# order 4
h = [17//48, 59//48, 43//48, 49//48, 1, 1, 1, 1]
H = Diagonal(h)

s = [-11//6, 3, -3//2, 1//3, 0, 0, 0, 0]

m1 = [12*b[1]//17 + 59//192*b[2] + 27010400129//345067064608*b[3] + 69462376031//2070402387648*b[4],
    -59//68*b[1] - 6025413881//21126554976*b[3] - 537416663//7042184992*b[4],
    2//17*b[1] - 59//192*b[2] + 213318005//16049630912*b[4]+2083938599//8024815456*b[3],
    3//68*b[1] - 1244724001//21126554976*b[3] + 752806667//21126554976*b[4],
    49579087//10149031312*b[3] - 49579087//10149031312*b[4],
    -1//784*b[4]+1//784*b[3],
    0, 0]
m2 = [m1[2],
    3481//3264*b[1] + BigInt(9258282831623875)//7669235228057664*b[3] + 236024329996203//1278205871342944*b[4],
    -59//408*b[1] - 29294615794607//29725717938208*b[3] - 2944673881023//29725717938208*b[4],
    -59//1088*b[1] + 260297319232891//2556411742685888*b[3] - 60834186813841//1278205871342944*b[4],
    -1328188692663//37594290333616*b[3] + 1328188692663//37594290333616*b[4],
    -8673//2904112*b[3] + 8673//2904112*b[4],
    0, 0]
m3 = [m1[3], m2[3],
    1//51*b[1] + 59//192*b[2] + 13777050223300597//26218083221499456*b[4] + 564461//13384296*b[5] + BigInt(378288882302546512209)//270764341349677687456*b[3],
    1//136*b[1] - 125059//743572*b[5] - 4836340090442187227//5525802884687299744*b[3] - 17220493277981//89177153814624*b[4],
    -10532412077335//42840005263888*b[4] + 1613976761032884305//7963657098519931984*b[3] + 564461//4461432*b[5],
    -960119//1280713392*b[4] - 3391//6692148*b[5] + 33235054191//26452850508784*b[3],
    0, 0]
m4 = [m1[4], m2[4], m3[4],
    3//1088*b[1] + BigInt(507284006600757858213)//475219048083107777984*b[3] + 1869103//2230716*b[5] + 1//24*b[6] + 1950062198436997//3834617614028832*b[4],
    -BigInt(4959271814984644613)//20965546238960637264*b[3] - 1//6*b[6] - 15998714909649//37594290333616*b[4] - 375177//743572*b[5],
    -368395//2230716*b[5] + 752806667//539854092016*b[3] + 1063649//8712336*b[4] + 1//8*b[6],
    0, 0]
m5 = [m1[5], m2[5], m3[5], m4[5],
    BigInt(8386761355510099813)//128413970713633903242*b[3] + 2224717261773437//2763180339520776*b[4] + 5//6*b[6] + 1//24*b[7] + 280535//371786*b[5],
    -35039615//213452232*b[4] - 1//6*b[7] - 13091810925//13226425254392*b[3] - 1118749//2230716*b[5] - 1//2*b[6],
    -1//6*b[6] + 1//8*b[5] + 1//8*b[7],
    0]
m6 = [m1[6], m2[6], m3[6], m4[6], m5[6],
    3290636//80044587*b[4] + 5580181//6692148*b[5] + 5//6*b[7] + 1//24*b[8] + 660204843//13226425254392*b[3] + 3//4*b[6],
    -1//6*b[5] - 1//6*b[8] - 1//2*b[6] - 1//2*b[7],
    -1//6*b[7] + 1//8*b[6] + 1//8*b[8]]
i=7; m7 = -[0, 0, 0, 0,
    b[i-1]/6 - b[i-2]/8 - b[i]/8,
    b[i-2]/6 + b[i+1]/6 + b[i-1]/2 + b[i]/2,
    -b[i-2]/24 - 5*b[i-1]/6 - 5*b[i+1]/6 - b[i+2]/24 - 3*b[i]/4,
    b[i-1]/6 + b[i+2]/6 + b[i]/2 + b[i+1]/2,
    #b[i+1]/6 - b[i]/8 - b[i+2]/8
    ]
i=8; m8 = -[0, 0, 0, 0, 0,
    b[i-1]/6 - b[i-2]/8 - b[i]/8,
    b[i-2]/6 + b[i+1]/6 + b[i-1]/2 + b[i]/2,
    -b[i-2]/24 - 5*b[i-1]/6 - 5*b[i+1]/6 - b[i+2]/24 - 3*b[i]/4,
    #b[i-1]/6 + b[i+2]/6 + b[i]/2 + b[i+1]/2,
    #b[i+1]/6 - b[i]/8 - b[i+2]/8
    ]
M = hcat(m1, m2, m3, m4, m5, m6, m7, m8)'

S = zeros(M)
S[1,:] = s

D2 = H \ (-M - b[1]*S)


# order 6
h = [13649//43200, 12013//8640, 2711//4320, 5359//4320, 7877//8640, 43801//43200,
    1, 1, 1, 1, 1, 1]
H = Diagonal(h)

s = [-25//12, 4, -3, 4//3, 1//4, 0, 0, 0, 0, 0, 0, 0]

ten = BigInt(10)//1
ten = 10.
m1 = [
    # 1
    79126675946955820939/ten^20*b[1] + 29684720906380007429/ten^20*b[2] + 31855190887964290152/ten^22*b[3] + 16324040425909519534/ten^21*b[4] + 31603022440944150877/ten^21*b[5] + 31679647480161052996/ten^21*b[6] + 31485777339472539205/ten^21*b[7],
    # 2
    -10166893393503381444/ten^19*b[1] - 28456273704916113690/ten^21*b[3] - 41280298383492988198/ten^21*b[4] - 13922814516201405075/ten^20*b[5] - 11957773256112017666/ten^20*b[6] - 11942677565293334109/ten^20*b[7],
    # 3
    70756429372437150463/ten^21*b[1] - 18454761060241510503/ten^20*b[2] - 43641631471118923470/ten^21*b[4] + 24323679072077324609/ten^20*b[5] + 15821270735372154440/ten^20*b[6] + 16023485783647863076/ten^20*b[7],
    # 4
    22519915328913532127/ten^20*b[1] - 16627487110970548953/ten^20*b[2] + 27105309616486712977/ten^21*b[3] - 19166461859684399091/ten^20*b[5] - 76841171601990145944/ten^21*b[6] - 82195869498316975759/ten^21*b[7],
    # 5
    -52244034642020563167/ten^21*b[1] + 44400639485098762210/ten^21*b[2] - 10239765473093878745/ten^22*b[3] + 74034846453161740905/ten^21*b[4] + 12416255689984968954/ten^21*b[6] + 71886528478926012827/ten^21*b[5] + 13793629971047355034/ten^21*b[7],
    # 6
    -18288968138771973527/ten^21*b[1] + 95746331632217580607/ten^22*b[2] - 81057845305764042779/ten^23*b[3] - 73488455877755196984/ten^22*b[4] + 10636019497239069970/ten^21*b[5] - 13159670383826183824/ten^21*b[6] - 21179364788387535246/ten^21*b[7],
    # 7
    19118885633161709274/ten^22*b[4] - 40681303555291499361/ten^21*b[5] + 13196749810737491670/ten^21*b[6] + 25572665181237836763/ten^21*b[7],
    # 8
    15596528711367857640/ten^21*b[5] - 64861841573315378995/ten^22*b[6] - 91103445540363197401/ten^22*b[7],
    # 9
    55939836966298630593/ten^23*b[6] - 13848225351007963723/ten^22*b[5] + 82542416543781006633/ten^23*b[7],
    # 10
    0, 0, 0]
m2 = [m1[2],
    # 2 #TODO: Check
    13063321571116676286/ten^19*b[1] + 25420017604573457435/ten^20*b[3] + 10438978280925626095/ten^20*b[4] + 66723280210321129509/ten^20*b[5] + 46818193597227494411/ten^20*b[6] + 46764154101958369201/ten^20*b[7],
    # 3
    -90914102699924646049/ten^21*b[1] + 11036113131714764253/ten^20*b[4] - 12903975449975188870/ten^19*b[5] - 66396052487350447871/ten^20*b[6] - 66159744640052061842/ten^20*b[7],
    # 4
    -28935573956534316666/ten^20*b[1] - 24213200040645927216/ten^20*b[3] + 11876702550280310277/ten^19*b[5] + 39565981499041363328/ten^20*b[6] + 38600489217558000007/ten^20*b[7],
    # 5
    67127744758037639890/ten^21*b[1] + 91471926820756301800/ten^22*b[3] - 18721961430038080217/ten^20*b[4] - 13193585588531745301/ten^20*b[6] - 48715757368119118874/ten^20*b[5] - 10475163122754481381/ten^20*b[7],
    # 6
    23499279745900688694/ten^21*b[1] + 72409053835651813164/ten^22*b[3] + 18583789963916794487/ten^21*b[4] - 92896161339386761743/ten^21*b[5] + 12235132704188076670/ten^20*b[6] + 11135203204362950339/ten^20*b[7],
    # 7
    -48347914064469075906/ten^22*b[4] + 23106838326878204031/ten^20*b[5] - 10807741421960079917/ten^20*b[6] - 11815617764273433354/ten^20*b[7],
    # 8
    -83681414344034553537/ten^21*b[5] + 40934994667670546616/ten^21*b[6] + 42746419676364006921/ten^21*b[7],
    # 9
    -35765451326969831434/ten^22*b[6] + 73893991241210786821/ten^22*b[5] - 38128539914240955387/ten^22*b[7],
    # 10
    0, 0, 0]
m3 = [m1[3], m2[3],
    # 3
    63271611471368738078/ten^22*b[1] + 11473182007158685275/ten^20*b[2] + 11667405542796800075/ten^20*b[4] + 27666108082854440372/ten^19*b[5] + 10709206899608171042/ten^19*b[6] + 10131613910329730572/ten^19*b[7],
    # 4
    20137694138847972466/ten^21*b[1] + 10337179946308864017/ten^20*b[2] - 29132216211517427243/ten^19*b[5] - 87558073434822622598/ten^20*b[6] - 69099571834888124265/ten^20*b[7],
    # 5
    -46717510915754628683/ten^22*b[1] - 27603533656377128278/ten^21*b[2] - 19792902986208699745/ten^21*b[4] + 54029853383734330523/ten^20*b[6] + 12391775930319110779/ten^19*b[5] + 26280380502473582273/ten^20*b[7],
    # 6
    -16354308669218878195/ten^22*b[1] - 59524752758832596197/ten^22*b[2] + 19646827777442752194/ten^21*b[4] + 32366400126390466006/ten^20*b[5] - 46595166932288709739/ten^20*b[6] - 22172727209417368594/ten^20*b[7],
    # 7
    -51113531893524745496/ten^22*b[4] - 53558781637747543460/ten^20*b[5] + 33283351044897389336/ten^20*b[6] + 20786565911785401579/ten^20*b[7],
    # 8
    18243281741342895622/ten^20*b[5] - 10598160301968184459/ten^20*b[6] - 76451214393747111630/ten^21*b[7],
    # 9
    92090899634437994856/ten^22*b[6] - 15915028188724931671/ten^21*b[5] + 67059382252811321853/ten^22*b[7],
    # 10
    0, 0, 0]
m4 = [m1[4], m2[4], m3[4],
    # 4
    64092997759871869867/ten^21*b[1] + 93136576388046999489/ten^21*b[2] + 23063676246347492291/ten^20*b[3] + 36894403082837166203/ten^19*b[5] + 11905503386876088738/ten^19*b[6] + 59124795468888565194/ten^20*b[7],
    # 5
    -14868958192656041286/ten^21*b[1] - 24870405993901607642/ten^21*b[2] - 87129289077117541871/ten^22*b[3] - 12635078373718242057/ten^19*b[6] - 30583173978439973269/ten^20*b[7] - 14706919260458029548/ten^19*b[5],
    # 6
    -52051474298559556576/ten^22*b[1] - 53630987475285424890/ten^22*b[2] - 68971427657906095463/ten^22*b[3] - 78575245216674501017/ten^20*b[5] + 22911480054237346001/ten^20*b[7] + 99770643562927505292/ten^20*b[6],
    # 7
    66972974880676622652/ten^20*b[5] - 50132473560721279390/ten^20*b[6] - 17951612431066454373/ten^20*b[7],
    # 8
    -20229090601117515652/ten^20*b[5] + 14534218580636584986/ten^20*b[6] + 56948720204809306656/ten^21*b[7],
    # 9
    -12004296184410038337/ten^21*b[6] - 47769156693859238415/ten^22*b[7] + 16781211853795962179/ten^21*b[5],
    # 10
    0, 0, 0]
m5 = [m1[5], m2[5], m3[5], m4[5],
    # 5
    34494550959102336252/ten^22*b[1] + 66411834994278261016/ten^22*b[2] + 32915450832718628585/ten^23*b[3] + 33577217075764772000/ten^20*b[4] + 20964133295790264390/ten^19*b[6] + 23173232041831268550/ten^20*b[7] + 61078257643682645765/ten^22*b[8] + 71091258506833766956/ten^20*b[5],
    # 6
    12075440723041938061/ten^22*b[1] + 14321166657521476075/ten^22*b[2] + 26055826461832559573/ten^23*b[3] - 33329411132516353908/ten^21*b[4] - 28082416973855326836/ten^20*b[7] - 27209080835250836084/ten^21*b[8] + 10458654356829219874/ten^20*b[5] - 13484369866671155432/ten^19*b[6],
    # 7
    86710380841746926251/ten^22*b[4] + 17360734113554285637/ten^20*b[6] + 53313621252876254126/ten^21*b[8] - 24249352624045263018/ten^20*b[5] + 15690152576785882706/ten^20*b[7],
    # 8
    -86316839802171222760/ten^21*b[6] + 26988423604709992435/ten^21*b[7] + 80981941477156510853/ten^21*b[5] - 32764636390806391639/ten^21*b[8],
    # 9
    74620594845308550733/ten^22*b[6] - 81216403616686789496/ten^23*b[7] + 55227020881270902093/ten^23*b[8] - 72021656571766961993/ten^22*b[5],
    # 10
    0, 0, 0]
m6 = [m1[6], m2[6], m3[6], m4[6], m5[6],
    # 6
    42272261734493450425/ten^23*b[1] + 30882419443789644048/ten^23*b[2] + 20625757066474306202/ten^23*b[3] + 33083434042009682567/ten^22*b[4] + 58280470164050018158/ten^20*b[5] + 80541742203662154736/ten^20*b[7] + 13383632334100334433/ten^20*b[8] + 55555555555555555556/ten^22*b[9] + 11903620718618930511/ten^19*b[6],
    # 7
    -86070442526864133026/ten^23*b[4] - 17480747086739049893/ten^20*b[5] - 31325448501150501650/ten^20*b[8] - 25000000000000000000/ten^21*b[9] - 31691663053104292713/ten^20*b[7] - 66916070916479291611/ten^20*b[6],
    # 8
    33546617916933521087/ten^21*b[5] - 33436200223869714050/ten^20*b[7] + 50000000000000000000/ten^21*b[9] + 21697906098076027508/ten^20*b[6] + 18383632334100334433/ten^20*b[8],
    # 9
    29125184768230046430/ten^21*b[7] + 22790919164749163916/ten^21*b[8] - 30689859975187405305/ten^21*b[6] - 17817995133473605962/ten^22*b[5] - 30555555555555555556/ten^21*b[9],
    # 10
    0, 0, 0]
    ]
i=7; m7 = [m1[7], m2[7], m3[7], m4[7], m5[7], m6[7],
    # 7
    22392237357715991790/ten^23*b[4] + 12754377854309566738/ten^20*b[5] + 10116994839296081646/ten^19*b[6] + 96988172751725752475/ten^20*b[8] + 12500000000000000000/ten^20*b[9] + 55555555555555555556/ten^22*b[10] + 48231775430312815001/ten^20*b[7],
    # 8
    -37841139730330129499/ten^21*b[5] - 29975568851348273616/ten^20*b[6] - 30000000000000000000/ten^20*b[9] - 25000000000000000000/ten^21*b[10] - 39914868674468211784/ten^20*b[7] - 43825448501150501650/ten^20*b[8],
    # 9
    46981462180226839339/ten^21*b[6] - 29668637874712374587/ten^20*b[8] + 50000000000000000000/ten^21*b[10] + 17163557041460064817/ten^20*b[7] + 30693461522962583624/ten^22*b[5] + 17500000000000000000/ten^20*b[9],
    # 10
    1//40*b[i+1] + 1//40*b[i+1] - 11//360*b[i+3] - 11//360*b[i],
    # 11
    0, 0]
    ]
i=8; m8 = [m1[8], m2[8], m3[8], m4[8], m5[8], m6[8], m7[8],
    # 8
    12303289427168044554/ten^21*b[5] + 11836475296458983325/ten^20*b[6] + 94105118982279433342/ten^20*b[7] + 95000000000000000000/ten^20*b[9] + 12500000000000000000/ten^20*b[11] + 55555555555555555556/ten^22*b[10] + 56994743445211445545/ten^20*b[8],
    # 9
    -23080678926719163396/ten^21*b[6] - 29866250537751494972/ten^20*b[7] - 30000000000000000000/ten^20*b[11] - 25000000000000000000/ten^21*b[10] - 10477348605150508026/ten^22*b[5] - 42720908083525083608/ten^20*b[8] - 42500000000000000000/ten^20*b[9],
    # 10
    1//20*b[i+3] - 3//10*b[i+1] + 1//20*b[i-1] + 7//40*b[i] + 7//40*b[i+2],
    # 11
    1//40*b[i+1] + 1//40*b[i+1] - 11//360*b[i+3] - 11//360*b[i],
    # 12
    0]
i=9; m9 = [m1[9], m2[9], m3[9], m4[9], m5[9], m6[9], m7[9], m8[9],
    # 9
    51393702211491099770/ten^22*b[6] + 12477232150094220014/ten^20*b[7] + 95055227020881270902/ten^20*b[8] + 95000000000000000000/ten^20*b[12] + 12500000000000000000/ten^20*b[11] + 55555555555555555556/ten^22*b[10] + 91593624651536418269/ten^24*b[5] + 56111111111111111111/ten^20*b[9],
    # 10
    -1//40*b[i+3] - 3//10*b[i-1] - 1//40*b[i-2] - 17//40*b[i] - 17//40*b[i+1],
    # 11
    1//20*b[i+3] - 3//10*b[i+1] + 1//20*b[i-1] + 7//40*b[i] + 7//40*b[i+2],
    # 12
    1//40*b[i+1] + 1//40*b[i+1] - 11//360*b[i+3] - 11//360*b[i],
    ]
i=10; m10 = -[0, 0, 0, 0, 0, 0,
    1//40*b[i-1] + 1//40*b[i-1] - 11//360*b[i-3] - 11//360*b[i],
    1//20*b[i-3] - 3//10*b[i-1] + 1//20*b[i+1] + 7//40*b[i] + 7//40*b[i-2],
    -1//40*b[i-3] - 3//10*b[i+1] - 1//40*b[i+2] - 17//40*b[i] - 17//40*b[i-1],
    1//180*b[i-3] + 1//8*b[i-2] + 19//20*b[i-1] + 19//20*b[i+1] + 1//8*b[i+2] + 1//180*b[i+3] + 101//180*b[i],
    -1//40*b[i+3] - 3//10*b[i-1] - 1//40*b[i-2] - 17//40*b[i] - 17//40*b[i+1],
    1//20*b[i+3] - 3//10*b[i+1] + 1//20*b[i-1] + 7//40*b[i] + 7//40*b[i+2],
    #1//40*b[i+1] + 1//40*b[i+1] - 11//360*b[i+3] - 11//360*b[i],
    ]
i=11; m11 = -[0, 0, 0, 0, 0, 0, 0,
    1//40*b[i-1] + 1//40*b[i-1] - 11//360*b[i-3] - 11//360*b[i],
    1//20*b[i-3] - 3//10*b[i-1] + 1//20*b[i+1] + 7//40*b[i] + 7//40*b[i-2],
    -1//40*b[i-3] - 3//10*b[i+1] - 1//40*b[i+2] - 17//40*b[i] - 17//40*b[i-1],
    1//180*b[i-3] + 1//8*b[i-2] + 19//20*b[i-1] + 19//20*b[i+1] + 1//8*b[i+2] + 1//180*b[i+3] + 101//180*b[i],
    -1//40*b[i+3] - 3//10*b[i-1] - 1//40*b[i-2] - 17//40*b[i] - 17//40*b[i+1],
    ]
i=12; m12 = -[0, 0, 0, 0, 0, 0, 0, 0,
    1//40*b[i-1] + 1//40*b[i-1] - 11//360*b[i-3] - 11//360*b[i],
    1//20*b[i-3] - 3//10*b[i-1] + 1//20*b[i+1] + 7//40*b[i] + 7//40*b[i-2],
    -1//40*b[i-3] - 3//10*b[i+1] - 1//40*b[i+2] - 17//40*b[i] - 17//40*b[i-1],
    1//180*b[i-3] + 1//8*b[i-2] + 19//20*b[i-1] + 19//20*b[i+1] + 1//8*b[i+2] + 1//180*b[i+3] + 101//180*b[i],
    ]
M = hcat(m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12)'

S = zeros(M)
S[1,:] = s

D2 = H \ (-M - b[1]*S)
