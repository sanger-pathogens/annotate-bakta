//
// Check input samplesheet and get read channels
//

workflow MANIFEST_PARSE {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    assemblies = Channel
        .fromPath( samplesheet )
        .ifEmpty {exit 1, "Cannot find path file ${samplesheet}"}
        .splitCsv ( header:true, sep:',' )
        .map { create_assembly_channels(it) }

    if (params.combine_annotations) {
        pre_generated_annotation_channel = Channel
            .fromPath( samplesheet )
            .ifEmpty {exit 1, "Cannot find path file ${samplesheet}"}
            .splitCsv ( header:true, sep:',' )
            .map { create_annotations_channels(it) }

    } else {
        pre_generated_annotation_channel = Channel.empty()
    }
    
    emit:
    assemblies
    pre_generated_annotation_channel
}

// Function to get list of [ meta, assembly ]
def create_assembly_channels(LinkedHashMap row) {
    def meta = [:]

    //for bakta
    meta.ID = row.ID.replace('#', '_')

    def array = []
    // check short reads
    if ( !(row.assembly == 'NA') ) {
        if ( !file(row.assembly).exists() ) {
            exit 1, "ERROR: Please check input samplesheet -> Assembly file does not exist!\n${row.assembly}"
        }
        assembly = file(row.assembly)
    }

    array = [ meta, assembly ]
    return array
}

// Function to get list of [ meta, assembly ]
def create_annotations_channels(LinkedHashMap row) {
    def meta = [:]

    //for bakta
    meta.ID = row.ID.replace('#', '_')

    def array = []
    // check short reads
    if ( row.annotations ) {
        annotations = file(row.annotations)
    } else {
        exit 1, "ERROR: Please check input samplesheet -> 'annotations' field is required if 'combine_annotations' parameter is set to true."
    }

    array = [ meta, annotations ]
    return array
}