
'align_doid_efo.tbl' <-- [],
  'blip-findall  -consult util/aligner.pro efo/2 -label -use_tabs > $@.tmp && sort -u $@.tmp > $@'.


'do-defs.tab' <-- [],
  'blip-findall -r disease "class(X,N),def(X,D)" -select "x(X,N,D)" -no_pred > $@'.

'dict.txt' <-- [],
  'blip-findall -r uberonp -r CL "class(ID,N)" -select N > $@'.

'run.out' <-- ['dict.txt', 'do-defs.tab'],
  './d-runner.pl -a -d dict.txt do-defs.tab > $@'.

'do-rels.txt' <-- 'run.out',
  './parse-results.pl -a do-defs.tab "ann/DOID_*/*" > $@'.

'do-rels-m.pro' <-- 'do-rels.txt',
  'blip-findall -consult util/map_dorel.pro -r fma3 -r uberonp -i $< -f "tbl(dorel)" mdorel/6 -write_prolog > $@'.

'do-rels-nr.txt' <-- 'do-rels-m.pro',
  'blip-findall  -table_pred subclassRT/2 -debug nr -r disease -consult util/nr_dorel.pro -r uberonp -i $<  nrdorel/6 -no_pred > $@.tmp && sort -u $@.tmp > $@'.
%  'blip-findall -debug index -index "ontol_db:subclassRT(1,1)" -debug nr -r disease -consult util/nr_dorel.pro -r uberonp -i $<  nrdorel/6 -no_pred > $@.tmp && sort -u $@.tmp > $@'.

'do-rels-nr.pro'  <-- 'do-rels-nr.txt',
  'tbl2p -p dorel $< > $@'.


'summary.txt' <-- 'do-rels-nr.txt',
  'perl -npe "s/:/\t/g" $<  | count-occ-group.pl 5 > $@'.


/*
'termlists' <-- ['do-rels-nr.pro'|Deps],
  {consult('do-rels-nr.pro'),
   setof([termlist,-,DB,'.txt'],
         (   dorel(D,DN,R,X,XN,Def
   }
  */

'summary2.txt' <-- 'do-rels-nr.pro',
  'blip-findall -f dorel -i $< "aggregate(count,DB,(dorel(D,DN,R,X,XN,Def),id_idspace(X,DB)),,id_idspace(X,\'$DB\')" -select X-XN -no_pred | sort -u > $@'.

'termlist-$DB.txt' <-- 'do-rels-nr.pro',
  'blip-findall -f dorel -i $< "dorel(D,DN,R,X,XN,Def),id_idspace(X,\'$DB\')" -select X-XN -no_pred | sort -u > $@'.


relmap(defgenus,is_a,'DOID').
relmap(results_in,results_in,'HP').
relmap(_,has_locus,'UBERON').
relmap(_,has_locus,'CL').
relmap(has_symptom,has_symptom,'SYMP').
relmap(_,has_phenotype,'MP').
relmap(_,has_phenotype,'HP').
relmap(transmitted_by,transmitted_by,'UBERON').
relmap(transmitted_by,transmitted_by,'TRANS').
relmap(transmitted_by,transmitted_by,'NCBITaxon').
relmap(has_material_basis,has_material_basis,'SYMP').
relmap(has_material_basis,has_material_basis,'NCBITaxon').
relmap(has_material_basis,has_material_basis,'GO').
relmap(has_material_basis,has_material_basis,'CL').
relmap(has_material_basis,has_material_basis,'UBERON').
relmap(caused,has_material_basis,'NCBITaxon').

        

'bridges' <-- Deps,
{findall(t(['do-bridge-',R,'-',NS,'.obo']),
         relmap(_,R,NS),
         Deps)},
   'touch $@'.


'do-bridge-$Rel-$NS.obo' <-- ['do-rels-nr.txt'],
  {relmap(RelIn,Rel,NS),(var(RelIn)->RelIn='.';true)},
  './tab-to-obo.pl $RelIn $Rel $NS $< > $@'.

% TODO
'do-x-$NS.obo' <-- Deps,
{findall(t(['do-bridge-',R,'-',NS,'.obo']),
         relmap(_,R,NS),
         Deps),
 findall(A,(member(t(L),Deps),concat_atom(L,A)),As),
 concat_atom(As,' ',DepsA)},
   'cat $DepsA > $@'.

'NCBITaxon_import.owl' <-- 'do-x-NCBITaxon.obo',
  'owltools $< http://purl.obolibrary.org/obo/ncbitaxon/subsets/taxslim.owl --add-imports-from-supports --extract-module -c -s http://purl.obolibrary.org/obo/ncbitaxon/subsets/taxslim.obo --extract-mingraph --set-ontology-id http://purl.obolibrary.org/obo/doid/extensions/import_NCBITaxon.owl -o file://`pwd`/$@ '.

'$NS_import.owl' <-- 'do-x-$NS.obo',
  {downcase_atom(NS,NS_dn)},
  'owltools $< http://purl.obolibrary.org/obo/$NS_dn.owl --add-imports-from-supports --extract-module -c -s http://purl.obolibrary.org/obo/$NS_dn.owl --extract-mingraph --set-ontology-id http://purl.obolibrary.org/obo/doid/extensions/$NS_import.owl -o.owl file://`pwd`/$@ '.




'do-idn.obo' <-- [],
  'blip ontol-query -r disease -query "class(ID)" -to obo | obo-filter-tags.pl -t id -t name -t def > $@'.


all <-- 'all-do-bridge.obo'.

'do-merged.obo' <-- ['do-idn.obo', bridges],
  'obo-merge-tags.pl -t id  -t is_a -t relationship $< do-bridge-*obo > $@'.

'all-do-bridge.obo' <-- bridges,
  'obo-merge-tags.pl -t id  -t is_a -t relationship -t intersection_of do-bridge-*obo > $@'.

'do-plus-axioms.owl' <-- 'all-do-bridge.obo',
  'owltools $< -o file://`pwd`/$@'.
