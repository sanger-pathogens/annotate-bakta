include { BAKTA   } from '../modules/bakta.nf'

workflow ANNOTATE_BAKTA {
    take:
    assembly_channel

    main:
    
    BAKTA(assembly_channel)

    emit:
    BAKTA.out.gff
}