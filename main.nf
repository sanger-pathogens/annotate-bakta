#!/usr/bin/env nextflow
// Copyright (C) 2024 Genome Research Ltd.

/*
========================================================================================
    HELP
========================================================================================
*/

def logo = NextflowTool.logo(workflow, params.monochrome_logs)

log.info logo

NextflowTool.commandLineParams(workflow.commandLine, log, params.monochrome_logs)


def printHelp() {
    NextflowTool.help_message("${workflow.ProjectDir}/schema.json", 
                               ["${workflow.ProjectDir}/assorted-sub-workflows/annotate_bakta/schema.json"],
    params.monochrome_logs, log)
}

/*
========================================================================================
    IMPORT MODULES/SUBWORKFLOWS
========================================================================================
*/

//
// SUBWORKFLOWS
//

include { MANIFEST_PARSE   } from './subworkflows/manifest_parse.nf'
include { ANNOTATE_BAKTA   } from './assorted-sub-workflows/annotate_bakta/subworkflows/annotate_bakta.nf'



/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

workflow {
    if (params.help) {
        printHelp()
        exit 0
    }

    manifest = file(params.manifest)

    MANIFEST_PARSE(manifest)
    | ANNOTATE_BAKTA

}
