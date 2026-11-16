import 'article.dart';

const publications = [
  Article(
    id: 'cac-expatriates',
    kind: ArticleKind.publication,
    source: 'Gulf Heart Journal',
    title:
        'Coronary calcium scoring sharpens risk prediction in South Asian residents of the UAE',
    authors: 'R. Menon, M. Al Suwaidi, J. Okafor et al.',
    hoursAgo: 20,
    readMinutes: 9,
    topic: 'Cardiology',
    featured: true,
    doi: '10.4172/ghj.2026.1184',
    summary:
        'Adding coronary artery calcium to standard risk equations reclassified one in four intermediate-risk patients in a 6,200-person cohort.',
    keyFindings: [
      '26% of intermediate-risk patients were reclassified after calcium scoring.',
      'A score of zero carried a 10-year event rate below 2%.',
      'Pooled cohort equations underestimated risk by 31% in this population.',
    ],
    figure: ArticleFigure(
      title: 'Observed 10-year events by calcium score',
      labels: ['0', '1–99', '100–399', '400+'],
      values: [1.8, 6.4, 12.9, 22.6],
      unit: '%',
    ),
    body: [
      'South Asian residents make up the largest expatriate community in the UAE and carry a disproportionate burden of premature coronary disease. Standard risk calculators, derived largely from Western cohorts, are known to misjudge risk in this group.',
      'We followed 6,212 asymptomatic adults aged 40 to 70 across three Dubai and Abu Dhabi centres for a median of 8.4 years. All participants underwent non-contrast cardiac CT at baseline, and outcomes were adjudicated by a blinded committee.',
      'Calcium scoring reclassified 26% of patients initially labelled intermediate risk — most of them downward. Patients with a score of zero had an observed 10-year event rate of 1.8%, supporting a de-escalation of preventive therapy in this subgroup.',
      'Conversely, a score above 400 identified a group whose event rate exceeded that of many patients with established disease. These findings support routine calcium scoring as a gatekeeper for statin intensity decisions in South Asian patients.',
    ],
  ),
  Article(
    id: 'ramadan-hba1c',
    kind: ArticleKind.publication,
    source: 'Journal of Gulf Endocrinology',
    title:
        'Structured education before Ramadan halves severe hypoglycaemia in type 2 diabetes',
    authors: 'S. Haddad, A. Rahman, L. Pereira et al.',
    hoursAgo: 46,
    readMinutes: 7,
    topic: 'Endocrinology',
    doi: '10.5530/jge.2026.0412',
    summary:
        'A two-session education programme delivered six weeks before Ramadan reduced severe hypoglycaemia by 52% across 14 primary care clinics.',
    keyFindings: [
      'Severe hypoglycaemia fell from 7.1% to 3.4% of fasting patients.',
      'HbA1c was stable through Ramadan in the education arm.',
      'Benefits were largest among patients on sulfonylureas.',
    ],
    figure: ArticleFigure(
      title: 'Severe hypoglycaemia during Ramadan',
      labels: ['Usual care', 'Education'],
      values: [7.1, 3.4],
      unit: '%',
    ),
    body: [
      'Most Muslim patients with type 2 diabetes choose to fast during Ramadan, often without adjusting therapy. Hypoglycaemia in the late afternoon remains the most feared complication.',
      'In this cluster-randomised trial, 14 clinics delivered either usual care or a structured two-session programme covering risk stratification, glucose monitoring and medication timing around suhoor and iftar.',
      'Severe hypoglycaemia was halved in the education arm, with no deterioration in glycaemic control. The intervention required under two hours of clinician time per patient.',
    ],
  ),
  Article(
    id: 'heat-stroke-cwi',
    kind: ArticleKind.publication,
    source: 'Desert Medicine Review',
    title:
        'On-site cold-water immersion and survival in exertional heat stroke',
    authors: 'K. Al Mazrouei, D. Fischer, P. Nair et al.',
    hoursAgo: 72,
    readMinutes: 6,
    topic: 'Emergency',
    doi: '10.3389/dmr.2026.0077',
    summary:
        'Cooling within 30 minutes of collapse was associated with zero mortality across 418 occupational heat stroke cases.',
    keyFindings: [
      'No deaths occurred when cooling began within 30 minutes.',
      'Delayed cooling raised the risk of organ injury fourfold.',
    ],
    figure: ArticleFigure(
      title: 'Acute kidney injury by time to cooling',
      labels: ['<30 min', '30–60', '60+'],
      values: [4.2, 11.8, 17.5],
      unit: '%',
    ),
    body: [
      'Outdoor workers in the Gulf face some of the most extreme heat exposure in the world. We reviewed 418 cases of exertional heat stroke treated at construction-site medical posts between 2021 and 2025.',
      'Every patient cooled by immersion within 30 minutes of collapse survived. Each 10-minute delay was associated with a measurable rise in acute kidney injury and length of stay.',
      'These results support placing immersion tubs at high-risk worksites and training first responders to “cool first, transport second”.',
    ],
  ),
  Article(
    id: 'carbapenem-gcc',
    kind: ArticleKind.publication,
    source: 'Arabian Journal of Infectious Disease',
    title: 'Carbapenem resistance across GCC tertiary hospitals, 2019–2025',
    authors: 'N. Al Hashemi, T. Varghese, M. Ibrahim et al.',
    hoursAgo: 120,
    readMinutes: 11,
    topic: 'Infectious disease',
    doi: '10.1016/ajid.2026.3301',
    summary:
        'Resistance in Klebsiella pneumoniae plateaued after 2023 in hospitals with mature stewardship programmes.',
    keyFindings: [
      'Resistance plateaued at 18% in hospitals with stewardship teams.',
      'Hospitals without programmes continued to rise to 29%.',
    ],
    figure: ArticleFigure(
      title: 'Carbapenem-resistant K. pneumoniae',
      labels: ['2019', '2021', '2023', '2025'],
      values: [11, 15, 18, 18.4],
      unit: '%',
    ),
    body: [
      'We pooled susceptibility data from 22 tertiary hospitals across the Gulf to track carbapenem resistance over seven years.',
      'Resistance rose steadily until 2023 and then stabilised — but only in hospitals running audit-and-feedback stewardship programmes.',
      'The divergence argues for stewardship as core infrastructure rather than an optional quality initiative.',
    ],
  ),
  Article(
    id: 'remote-hf',
    kind: ArticleKind.publication,
    source: 'Gulf Heart Journal',
    title:
        'Remote monitoring after heart-failure discharge: 12-month readmissions',
    authors: 'F. Al Ali, G. Thomas, M. Al Suwaidi et al.',
    hoursAgo: 190,
    readMinutes: 8,
    topic: 'Cardiology',
    doi: '10.4172/ghj.2026.1201',
    summary:
        'Daily weight and symptom telemetry reduced 12-month readmissions by 23% in a pragmatic trial of 1,040 patients.',
    keyFindings: [
      'All-cause readmissions fell by 23% at 12 months.',
      'Adherence to daily readings stayed above 80%.',
    ],
    figure: ArticleFigure(
      title: '12-month readmission rate',
      labels: ['Standard', 'Remote'],
      values: [38.5, 29.6],
      unit: '%',
    ),
    body: [
      'Readmission after heart-failure hospitalisation remains common and costly. We randomised 1,040 patients at discharge to standard follow-up or daily remote monitoring.',
      'A nurse-led team reviewed alerts each morning and adjusted diuretics by phone. Readmissions fell by almost a quarter with high patient adherence.',
    ],
  ),
];

const news = [
  Article(
    id: 'heat-triage',
    kind: ArticleKind.news,
    source: 'Wellnest Newsroom',
    title: 'Emirates hospitals align on a single heat-stress triage protocol',
    authors: 'Wellnest Newsroom',
    hoursAgo: 2,
    readMinutes: 4,
    topic: 'Public health',
    featured: true,
    summary:
        'Emergency departments will use one shared scoring tool for heat illness from next summer, with mandatory refresher training.',
    body: [
      'Emergency departments across the country will adopt a unified heat-stress triage score ahead of next summer, replacing a patchwork of local tools.',
      'Clinicians will be asked to complete a short refresher module, which counts toward annual CME requirements.',
      'Hospital leaders say a single protocol will make inter-facility transfers faster and data comparable for the first time.',
    ],
  ),
  Article(
    id: 'cme-framework',
    kind: ArticleKind.news,
    source: 'Wellnest Newsroom',
    title: 'CME framework to recognise interdisciplinary learning hours',
    authors: 'Wellnest Newsroom',
    hoursAgo: 7,
    readMinutes: 3,
    topic: 'Licensing',
    summary:
        'Credits earned in joint nursing, pharmacy and physician sessions will count fully toward licence renewal.',
    body: [
      'Updated guidance means credits earned in interdisciplinary sessions will now count in full toward licence renewal for every participating profession.',
      'The change aims to encourage team-based learning, particularly in emergency and critical care settings.',
    ],
  ),
  Article(
    id: 'genome-map',
    kind: ArticleKind.news,
    source: 'Science Desk',
    title: 'Reference genome study passes 1,200 fully sequenced families',
    authors: 'Science Desk',
    hoursAgo: 15,
    readMinutes: 5,
    topic: 'Genomics',
    summary:
        'Early analysis points to founder variants that could reshape newborn screening panels.',
    body: [
      'A national reference genome study has now fully sequenced more than 1,200 families, giving researchers an unprecedented view of local genetic diversity.',
      'Early results highlight founder variants linked to inherited cardiomyopathies and metabolic disease — findings that may reshape newborn screening.',
    ],
  ),
  Article(
    id: 'telehealth',
    kind: ArticleKind.news,
    source: 'Policy Watch',
    title: 'What cross-emirate telehealth licensing means for your practice',
    authors: 'Policy Watch',
    hoursAgo: 28,
    readMinutes: 6,
    topic: 'Licensing',
    summary:
        'A practical guide to consulting patients in another emirate under the updated telehealth rules.',
    body: [
      'Updated rules make it simpler for licensed physicians to consult patients located in another emirate by video.',
      'Practitioners will need a telehealth endorsement on their existing licence, which can be requested during renewal.',
    ],
  ),
  Article(
    id: 'ecg-patch',
    kind: ArticleKind.news,
    source: 'Science Desk',
    title: 'Wearable ECG patch trial opens enrolment in Abu Dhabi',
    authors: 'Science Desk',
    hoursAgo: 52,
    readMinutes: 3,
    topic: 'Cardiology',
    summary:
        'The 14-day patch study will test earlier detection of atrial fibrillation in adults over 55.',
    body: [
      'A new trial will test whether a 14-day adhesive ECG patch detects atrial fibrillation earlier than routine screening in adults over 55.',
      'Cardiologists can refer eligible patients through the study portal from this month.',
    ],
  ),
];
