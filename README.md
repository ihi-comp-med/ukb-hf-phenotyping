# ukb-hf-phenotyping
Heart failure phenotyping algorithm implemented in UK Biobank.

This repository contains methods and codes to implement phenotyping algorithm to define heart failure (HF) cases and its subtypes in UK Biobank cohort.
The algorithm will define five subphenotypes of HF as illustrated in the following diagram:
![](hf_algorithm.png)

The five phenotypes are:

| Phenotype       | Abbreviation           | Description                                                     |
|--------|------------|-----------------------------------------------------|
| Pheno1 | All HF     | Clinical syndrome of HF, any cause or manifestation |
| Pheno2 | CM HF      | HF excluding CAD, valvular or congenital HD         |
| Pheno3 | CM HFrEF   | HFrEF excluding CAD, valvular or congenital HD      |
| Pheno4 | CM HFpEF   | HFpEF excluding CAD, valvular or congenital HD      |
| Pheno5 | DCM / HNDC | Dilated cardiomyopathy / hypokinetic non-dilated cardiomyopathy    |

