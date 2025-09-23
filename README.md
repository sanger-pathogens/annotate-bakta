# mags_maker

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A521.04.0-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

[[_TOC_]]

## Introduction

**annotate-bakta** is a convenience wrapper around the community standard bacterial genome annotation software [Bakta](https://github.com/oschwengers/bakta). It allows running this software on large batches of genomes taking advantage of the convenient automation of a Nextflow pipeline to process all genomes in parallel.
In addition this pipeline allows to combine previously generated annotation in GFF3 format with the Bakta anotation generated in this pipeline.

In the future, this pipeline may be further developed to include other annotation modules, which will all be combined into a final annotation file. please contact [pam-informatics@sanger.ac.uk](mailto:pam-informatics@sanger.ac.uk) if you're interested in such features.

## Pipeline summary

There is two stages in this pipeline: 1) Bakta annotation of genomes and, optionally, 2) combining previously pgenerated annotation with Bakta's.

## Getting started

### Running on the farm (Sanger HPC clusters)

1. Load nextflow and singularity modules:

   ```bash
   module load nextflow ISG/singularity
   ```

2. Either:

   - Clone this repository using `git clone --recurse-submodules`  
     OR
   - Load the software via a module: `module load annotate_bakta`  
     :warning: If using the module installed on the Sanger "farm" HPC, please replace `nextflow run main.nf` with `annotate_bakta` in all subsequent commands.

3. Start the pipeline  
   For example inputs, please see [Generating a manifest](#generating-a-manifest).

   Example:

   ```bash
   nextflow run main.nf --manifest ./test_data/inputs/test_manifest.csv --outdir my_output
   ```

   It is good practice to submit a dedicated job for the nextflow master process (use the `oversubscribed` queue):

   ```bash
   bsub -o output.o -e error.e -q oversubscribed -R "select[mem>4000] rusage[mem=4000]" -M4000 nextflow run main.nf --manifest ./test_data/inputs/test_manifest.csv --outdir my_output
   ```

   See [usage](#usage) for all available pipeline options.

4. Once your run has finished, check output in the `outdir` and clean up any intermediate files. To do this (assuming no other pipelines are running from the current working directory) run:

   ```bash
   rm -rf work .nextflow*
   ```

> :warning:
> It is strongly recommended that you don't run more than 100 samples at a time through this pipeline to reduce vulnerabilities to transient errors - e.g. LSF and I/O errors.

### Other supported environments

Currently, you can also run this pipeline on a dedicated host machine containing docker (using `-profile docker`) or (`-profile singularity`). No other environments are natively supported at this time.

## Generating a manifest

This pipeline has several input parameters that allow read data to be read from the local disk (on the SAnger HPC, this means on the NFS and Lustre filsytems)

Please provide a CSV (comma-separated value) file with two columns and header names `ID` and`assembly` specifying the identifier and the path to the genome assembly file in Fasta sequence file format, e.g.:

```
ID,assembly
Ecoli_Strain1,/data/pam/teamXXX/userYYY/scratch/projectZZZ/assemblies/Ecoli_Strain1.fa
Ecoli_Strain2,/data/pam/teamXXX/userYYY/scratch/projectZZZ/assemblies/Ecoli_Strain2.fa
Vchol_Strain1,/data/pam/teamXXX/userYYY/scratch/projectZZZ/assemblies/Vchol_Strain1.fa
MAG1,/data/pam/teamXXX/userYYY/scratch/projectAAA/MAGs/AAA_bin1.fa
MAG2,/data/pam/teamXXX/userYYY/scratch/projectAAA/MAGs/AAA_bin2.fa
```

In addition, previously generated annotation in GFF3 format may be combined with the Bakta anotation generated in this pipeline. These annotation files should be provided in the input manifest by adding a column with header `annotations`, e.g.:

```
ID,assembly,annotations
Ecoli_Strain1,/data/pam/teamXXX/userYYY/scratch/projectZZZ/assemblies/Ecoli_Strain1.fa,/data/pam/teamXXX/userYYY/scratch/projectZZZ/annotations/Ecoli_Strain1.gff
Ecoli_Strain2,/data/pam/teamXXX/userYYY/scratch/projectZZZ/assemblies/Ecoli_Strain2.fa,/data/pam/teamXXX/userYYY/scratch/projectZZZ/annotations/Ecoli_Strain2.gff
Vchol_Strain1,/data/pam/teamXXX/userYYY/scratch/projectZZZ/assemblies/Vchol_Strain1.fa,/data/pam/teamXXX/userYYY/scratch/projectZZZ/annotations/Vchol_Strain1.gff
MAG1,/data/pam/teamXXX/userYYY/scratch/projectAAA/MAGs/AAA_bin1.fa,
MAG2,/data/pam/teamXXX/userYYY/scratch/projectAAA/MAGs/AAA_bin2.fa,

## Usage

```

---

Annotation Pipeline options
--manifest
default:
Manifest containing paths to fasta genomic DNA sequence files with header containing at least the columns: ID,assembly. (mandatory)

      --combine_annotations
            default: false
            Previously generated annotation in GFF3 format are to be combined with the Bakta anotation generated in this pipeline. These annotation files should be provided in the input manifest by adding a column with header `annotations`.

---

Annotation
--bakta_args
default:
Supply bakta arguments as a string, e.g. '--proteins <full path>'. Avoid the use of --prefix, --locus-tag, --keep-contig-headers, for which values are supplied by the pipeline.
--bakta_db
default: /data/pam/software/bakta/v6.0/
Absolute path to the Bakta DB used for annotation.
--publish_gbff
default: false
Save gbff (GBK) files into a /gbff directory
--combine_annotations
default: false
EXPERIMENTAL: Combine annotations that you have produced seperately into the main bakta produced annotation

---

Logging options
--monochrome_logs
default: false
Should logs appear in plain ASCII

---

```

## Output and intermediate file cleanup

By default, this pipeline will publish the results to a `results` folder, this can be changed using the `--outdir` argument.

For instance, the output directory could look like:

```

```

Output folders are described in the following table:
| folder | description |
| --------- | --------------------------------------------------------- |

## Credits

This pipeline was originally designed as a reimplementation of metaWRAP (based on version 1.3.2; https://github.com/bxlab/metaWRAP). For further information please refer to the MetaWRAP paper: [MetaWRAP - a flexible pipeline for genome-resolved metagenomic data analysis](https://microbiomejournal.biomedcentral.com/articles/10.1186/s40168-018-0541-1)

## Support

For further information or help, don't hesitate to get in touch via [pam-informatics@sanger.ac.uk](mailto:pam-informatics@sanger.ac.uk).
```
