# ukb-hf-phenotyping
Heart failure phenotyping algorithm implemented in UK Biobank.

This repository contains methods and codes to implement phenotyping algorithm to define heart failure (HF) cases and its subtypes in UK Biobank cohort.
The algorithm will define five subphenotypes of HF as illustrated in the following diagram:

![](img/hf_algorithm.png)


## Phenotype definition

| Abbreviation           | Description                                                     |
|------------|-----------------------------------------------------|
| All HF     | Clinical syndrome of heart failure (HF) of any cause or manifestation |
| CM HF      | HF excluding coronary artery diseases (CAD), valvular or congenital heart diseases (HD)         |
| CM HFrEF   | HF with reduced ejection fraction (EF), excluding CAD, valvular or congenital HD      |
| CM HFpEF   | HF with preserved EF, excluding CAD, valvular or congenital HD      |
| DCM / HNDC | Dilated cardiomyopathy / hypokinetic non-dilated cardiomyopathy    |
