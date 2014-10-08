CQPFilter
=========

A feature-extraction system to generate CQBWeb/CQB compatible corpora from CLAWS SMT files.

Execution
---------

The filtering process proceeds in two stages:

 1. `clean_smt.rb` processes a directory full of .smt files, parses the XML stack as output by CLAWS, and produces CWB-format .vrt files (with XML markup) in an output directory.  This makes the assumption that the input was once valid XML, but will try to repair what isn't.

 2. `index_vrt.rb' constucts an index for CQBWeb, reading a directory full of .vrt files and summarising their properties at the file level.  To do this, it runs a series of feature extractors on the texts (these extractors process .vrt files to identify certain fields).


Configuration
-------------

### SMT Cleaning
The SMT processing stage can be configured using constants at the top of the script:

 * PROGRESS_OUTPUT: output to the screen every n loop iterations.  Handy to check the script's working.
 * TAG_BLACKLIST: CLAWS outputs 's' tags without caring about the well-formedness of XML.  Use this list to correct it by ignoring the tags.
 * INPUT_ENCODING: Does what it says on the tin.  CLAWS works in ISO8859-1.


### Index Construction
The extractors are instances of classes extending `index\_exractors/extractor.rb` and are configured in a key-value mapping at the top of the script.  This maps between the name given to the attribute in the index, and the value extracted.

 * METADATA_FIELDS: A key-value mapping from the name of each attribute to the instance of an extractor used to retrieve it from a VRT document.

