# annotate-bakta

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A521.04.0-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

[[_TOC_]]

## Pipeline overview

**annotate-bakta** is a Nextflow DSL2 pipeline for annotating bacterial genomes at scale using [Bakta](https://github.com/oschwengers/bakta). It runs Bakta on all input assemblies in parallel and, optionally, merges the resulting annotations with pre-existing GFF3 annotation files.

The pipeline performs the following steps:

1. **Annotation** — Bakta annotates each input assembly FASTA, producing GFF3, GBK/GBFF, FAA (proteins), and other standard annotation outputs.
2. **Annotation merging** (optional, `--combine_annotations`) — previously generated GFF3 annotations are merged with the Bakta output for each sample.

:warning: It is strongly recommended to run no more than 100 samples per pipeline invocation to reduce exposure to transient LSF and I/O errors.

## Usage

### Quickstart

#### From source code

1. Clone this repository (including submodules):

   ```bash
   git clone --recurse-submodules https://gitlab.internal.sanger.ac.uk/sanger-pathogens/pipelines/annotate-bakta.git
   cd annotate-bakta
   ```

2. To run with `docker`, use the `-profile docker` option:

   ```bash
   nextflow run main.nf \
       -profile docker \
       --manifest manifest.csv \
       --outdir my_output
   ```

   Other profiles are also supported (`singularity`).  
   :warning: If no profile is specified the pipeline will run with the Sanger HPC-specific configuration.

3. Once the run has finished, clean up intermediate files:

   ```bash
   rm -rf work .nextflow*
   ```

#### Using on the Sanger farm

First load the latest pipeline module:

```bash
module load annotate-bakta
```

Then run on the command line. For instance, to see a help message:

```bash
annotate-bakta --help
```

Submit to LSF:

```bash
bsub -o output.o -e error.e -q oversubscribed -R "select[mem>4000] rusage[mem=4000]" -M4000 \
    annotate-bakta \
        --manifest manifest.csv \
        --outdir my_output
```

### Input

#### Manifest (`--manifest`)

A CSV file with at least the columns `ID` and `assembly`:

```
ID,assembly
Ecoli_Strain1,/path/to/Ecoli_Strain1.fa
MAG1,/path/to/MAG1.fa
```

When using `--combine_annotations`, add an `annotations` column with paths to existing GFF3 files. Leave blank for samples without pre-existing annotations:

```
ID,assembly,annotations
Ecoli_Strain1,/path/to/Ecoli_Strain1.fa,/path/to/Ecoli_Strain1.gff
Ecoli_Strain2,/path/to/Ecoli_Strain2.fa,
```

### Output

Results are written to `--outdir` (default: `./results`):

```
results/
  gffs/
    <sample_ID>.gff3                  # Bakta annotation in GFF3 format
  gbff/
    <sample_ID>.gbff                  # GenBank flat file (if --publish_gbff)
  combined_gffs/
    <sample_ID>_merged_annotation.gff3  # Merged GFF3 annotation (if --combine_annotations)
```

### Parameters

**Annotation pipeline options**

| Option                  | Type      | Default    | Description                                                                                            |
| ----------------------- | --------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| `--manifest`            | `path`    | (required) | Input manifest CSV with header `ID,assembly` (and optionally `annotations`).                           |
| `--combine_annotations` | `boolean` | `false`    | Merge pre-existing GFF3 annotations (supplied in the manifest `annotations` column) with Bakta output. |

---

**Annotation options**

| Option           | Type      | Default                          | Description                                                                                                                                                                          |
| ---------------- | --------- | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `--bakta_db`     | `path`    | `/data/pam/software/bakta/v6.0/` | Path to the Bakta database directory.                                                                                                                                                |
| `--bakta_args`   | `string`  | `""`                             | Additional Bakta arguments as a string (e.g. `--proteins /path/to/proteins.faa`). Do not pass `--prefix`, `--locus-tag`, or `--keep-contig-headers` — these are set by the pipeline. |
| `--publish_gbff` | `boolean` | `false`                          | Publish GBFF/GBK annotation files to the output directory.                                                                                                                           |

---

**Logging options**

| Option              | Type      | Default     | Description                          |
| ------------------- | --------- | ----------- | ------------------------------------ |
| `--outdir`          | `path`    | `./results` | Directory where results are written. |
| `--monochrome_logs` | `boolean` | `false`     | Output logs in plain ASCII.          |

### Dependencies

All software dependencies are containerised. The Bakta database must be available locally:

- **Bakta database** (`--bakta_db`): download with `bakta_db download --output <path> --type full`. On the Sanger HPC, the database is pre-configured at the default path.

## Software versions

| Software | Version | Image                                   |
| -------- | ------- | --------------------------------------- |
| Bakta    | 1.12.0  | `quay.io/sangerpathogens/bakta:1.12.0`  |
| gffutils | 0.13    | `quay.io/sangerpathogens/gffutils:0.13` |

See `assorted-sub-workflows/annotate_bakta/modules/` for pinned container versions.

## Troubleshooting

- **Bakta database not found**: ensure `--bakta_db` points to a valid Bakta database directory. Download it with `bakta_db download --type full`.
- **Memory errors**: Bakta is memory-intensive for large assemblies. Increase memory via a custom Nextflow configuration file.
- **Resuming a failed run**: add `-resume` to restart from cached intermediate results.
- For further help, check `.nextflow.log` and the per-process `.command.log` logs in the `work/` directory.

Sanger users may find [this page](https://ssg-confluence.internal.sanger.ac.uk/spaces/PaMI/pages/181078206/General+pipeline+info#Generalpipelineinfo-Troubleshootingafailedpipelinerunandsendingabugreport) useful for troubleshooting Nextflow pipeline runs.

## Issues and Contributions

**GitHub users:** if you find an issue with this pipeline, or would like to suggest an improvement, please log an issue or open a pull request on this repository.

**Sanger users:** if you need internal support, you can raise an issue on the PAM Freshservice portal: https://sanger.freshservice.com/support/catalog/items/426
