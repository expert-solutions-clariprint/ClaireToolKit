// ********************************************************************
// * CHOCO, version 0.38 1/12/2000                                   *
// * file: init.cl                                                    *
// *    module definition                                             *
// * Copyright (C) F. Laburthe, 2000, see readme.txt                  *
// ********************************************************************

(Compile/FCALLSTINKS := true)

choco :: module(source = "source",
                version = "1.3.26",
                uses = list(Core, Reader),
                made_of = list( "chocutils","model","dom","prop","var","const",
                                "intconst1","intconst2","boolconst","setconst",
                                "search","chocapi","opapi","compil"))  // remove opapi for the java version


(Generate/C++PRODUCER.Generate/bad_names :add symbol!("union"),
 Generate/C++PRODUCER.Generate/good_names :add symbol!("UNION"))

(load(choco))

