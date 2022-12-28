%this program converts the entries of library.bib to html. This works only with .bib files created by Mendeley Desktop
system(['del ' sprintf('"') 'HTML citations\*.html' sprintf('"')]);

clear all

disp('-----')
disp(['This program will convert a bibtex library to a collection of simple HTML files.'])
disp('-----')
disp('Loading Library')
library=fileread('library.bib');


disp('-----')
disp('Library loaded')
disp('-----')
disp('Modifying some code for better HTML compatibility')

library=strrep(library,['{\' sprintf('''') '{a}}'],'á');
library=strrep(library,['{\' sprintf('''') '{e}}'],'é');
library=strrep(library,['{\' sprintf('''') '{i}}'],'í');
library=strrep(library,['{\' sprintf('''') '{o}}'],'ó');
library=strrep(library,['{\' sprintf('''') '{u}}'],'ú');

library=strrep(library,['{\' sprintf('''') '{A}}'],'Á');
library=strrep(library,['{\' sprintf('''') '{E}}'],'É');
library=strrep(library,['{\' sprintf('''') '{I}}'],'Í');
library=strrep(library,['{\' sprintf('''') '{O}}'],'Ó');
library=strrep(library,['{\' sprintf('''') '{U}}'],'Ú');

library=strrep(library,['{\~{a}}'],'ã');
library=strrep(library,['{\~{e}}'],'?');
library=strrep(library,['{\~{i}}'],'?');
library=strrep(library,['{\~{o}}'],'õ');
library=strrep(library,['{\~{u}}'],'?');

library=strrep(library,['{\^{a}}'],'â');
library=strrep(library,['{\^{e}}'],'ê');
library=strrep(library,['{\^{i}}'],'î');
library=strrep(library,['{\^{o}}'],'ô');
library=strrep(library,['{\^{u}}'],'û');

library=strrep(library,'{\$}','$');
library=strrep(library,'{\^{}}','^');
library=strrep(library,'{\c{c}}','ç');
library=strrep(library,'{\{}','{');
library=strrep(library,'{\}}','}');
library=strrep(library,'{\l}','&lstrok;');
library=strrep(library,'{\L}','&Lstrok;');
library=strrep(library,'{\&}','&amp;');
library=strrep(library,'{\_}','_');

library=strrep(library,'{\`{a}}','à');
library=strrep(library,'{\`{e}}','è');
library=strrep(library,'{\`{i}}','ì');
library=strrep(library,'{\`{o}}','ò');
library=strrep(library,'{\`{p}}','ù');


disp('-----')
disp('Code modified')

library=[library '@'];

disp('-----')
disp('Finding bib entries')

entries=strfind(library,'@');

disp('-----')
disp(['There are ' int2str(length(entries)-1) ' entries.'])

loadbar=waitbar(0,'Working...');
for i=1:length(entries)-1
  %create a string with the bibtex entry
  entry=library(entries(i):entries(i+1)-1);
  
  ref_type=entry(2:strfind(entry,'{')-1);
  %erase unnecessary whitespaces
  while isstrprop(entry(length(entry)),'wspace')
    entry(length(entry))='';
  endwhile
  %also add a comma at the end if it exists. The properties will always be between a '{' and a [',' sprintf('\n')]
  %entry(length(entry)) should be a '}'; This is ok
  
  %entry(length(entry)-1) should be a sprintf('\n');
  if 1-strcmp(entry(length(entry)-1),sprintf('\n'))
    entry=[entry(1:length(entry)-1) sprintf('\n') entry(length(entry)-1:length(entry))];
  endif
	
  %entry(length(entry)-2) should be a comma.
  if 1-strcmp(entry(length(entry)-2),',')
    entry=[entry(1:length(entry)-2) ',' entry(length(entry)-1:length(entry))];
  endif
  
  key_start=strfind(entry,'{')(1)+1;
  key_end=strfind(entry,[sprintf(',\n')])(1)-1;
  
  key=entry(key_start:key_end);
  
  properties_start=strfind(entry,sprintf('\n'))+1;
  
  for j=1:length(properties_start)-1
  
    prop=entry(properties_start(j):properties_start(j+1)-2); %-2 to remove sprintf('\n') and comma
    property_name{j}=prop(1:strfind(prop,'=')-1);
    property{j}=prop(strfind(prop,'=')+1:length(prop));
    %erase whitespaces
    
    while isstrprop(property_name{j}(1),'wspace')
      property_name{j}(1)='';
    endwhile
    
    while isstrprop(property_name{j}(length(property_name{j})),'wspace')
      property_name{j}(length(property_name{j}))='';
    endwhile
    
    while isstrprop(property{j}(1),'wspace')
      property{j}(1)='';
    endwhile
    
    while isstrprop(property{j}(length(property{j})),'wspace')
      property{j}(length(property{j}))='';
    endwhile
    
    %remove comma
    while strcmp(property{j}(length(property{j})),',')
      property{j}(length(property{j}))='';
    endwhile
    
    %Remove unnecessary brackets 
    while strcmp(property{j}(1),'{') && strcmp(property{j}(length(property{j})),'}')
      property{j}(1)='';
      property{j}(length(property{j}))='';
    endwhile
  endfor
	
  %find the title
	if length(find(strcmp(property_name,'title')))>0
    j=find(strcmp(property_name,'title'));
    title=property{j};
    
    str_title=['<b>Title</b>: ' title];
    
  else
    str_title='';
  endif
  
  %find the doi
	if length(find(strcmp(property_name,'doi')))>0
    j=find(strcmp(property_name,'doi'));
    doi=property{j};
    
    str_doi=['<br><b>DOI</b>: <a href=' sprintf('''') 'https://doi.org/' doi sprintf('''') '>' doi '</a>'];
    
  else
    str_doi='';
  endif
  
  %find the journal
	if length(find(strcmp(property_name,'journal')))>0
    j=find(strcmp(property_name,'journal'));
    journal=property{j};
    
    %find the volume
    if length(find(strcmp(property_name,'volume')))>0
      volume=property{find(strcmp(property_name,'volume'))};
      
      str_volume=[' ' volume];
    else
      str_volume='';
    endif
    
    %find the number
    if length(find(strcmp(property_name,'number')))>0
      number=property{find(strcmp(property_name,'number'))};
      
      str_number=['(' number ')'];
    else
      str_number='';
    endif
    
    str_journal=['<br><b>Journal</b>: ' journal str_volume str_number];
    
  else
    str_journal='';
  endif
  
  %find the year
	if length(find(strcmp(property_name,'year')))>0
    j=find(strcmp(property_name,'year'));
    year=property{j};
    
    str_year=['<br><b>Year</b>: ' year];
    
  else
    str_year='';
  endif
  
  %find the arxivID
	if length(find(strcmp(property_name,'arxivID')))>0
    j=find(strcmp(property_name,'arxivID'));
    arxivID=property{j};
    
    str_arxivID=['<br><b>arXiv ID</b>: <a href=' sprintf('''') 'arxiv.org/abs/' arxivID '</a>'];
    
  else
    str_arxivID='';
  endif
  
  %find the publisher
	if length(find(strcmp(property_name,'publisher')))>0
    j=find(strcmp(property_name,'publisher'));
    publisher=property{j};
    
    str_publisher=['<br><b>Publisher</b>: ' publisher];
    
  else
    str_publisher='';
  endif
  
  %find the series
	if length(find(strcmp(property_name,'series')))>0
    j=find(strcmp(property_name,'series'));
    series=property{j};
    
    str_series=['<br><b>Series</b>: ' series];
    
  else
    str_series='';
  endif
  
  %find the volume
	if length(find(strcmp(property_name,'volume')))>0
    j=find(strcmp(property_name,'volume'));
    volume=property{j};
    
    str_volume=['<br><b>Volume</b>: ' volume];
    
  else
    str_volume='';
  endif
  
  %find the booktitle for 'incollection'
	if length(find(strcmp(property_name,'booktitle')))>0
    j=find(strcmp(property_name,'booktitle'));
    booktitle=property{j};
    
    str_booktitle=['<br>In <i>' booktitle '</i>'];
    
  else
    str_booktitle='';
  endif
  
  %find the school for 'phdthesis'
	if length(find(strcmp(property_name,'school')))>0
    j=find(strcmp(property_name,'school'));
    school=property{j};
    
    str_school=['<br><b>Institution</b>: ' school];
    
  else
    str_school='';
  endif
  
  %find the type for 'phdthesis'
    if length(find(strcmp(property_name,'type')))>0
    j=find(strcmp(property_name,'type'));
    type=property{j};
    
    str_type=['<br><b>Type of work</b>: ' type];
    
  else
    str_type='';
  endif
  
  %find the authors
	if length(find(strcmp(property_name,'author')))>0
    j=find(strcmp(property_name,'author'));
    list_of_authors=property{j};
    list_of_authors=[' and ' list_of_authors ' and '];
    author={};
    for k=1:length(strfind(list_of_authors,' and '))-1;
      author{k}=list_of_authors(strfind(list_of_authors,' and ')(k)+length(' and '):strfind(list_of_authors,' and ')(k+1)-1);
    endfor
    
    for k=1:length(author)
      author{k}=[author{k}(strfind(author{k},', ')+2:length(author{k})) ' ' author{k}(1:strfind(author{k},', ')-1)];
    endfor
    
    if length(author)==1;
      str_author=['<br><b>Author</b>: ' author{1}];
    else
      str_author=['<br><b>Authors</b>: '];
      for k=1:length(author)
        if k<length(author)-1
          str_author=[str_author author{k} ', '];
        elseif k==length(author)-1
          str_author=[str_author author{k} ' and '];
        elseif k==length(author)
          str_author=[str_author author{k}];
        endif
        
      endfor
    endif
    
  else
    str_author='';
  endif
  
  %find the authors
	if length(find(strcmp(property_name,'editor')))>0
    j=find(strcmp(property_name,'editor'));
    list_of_editors=property{j};
    list_of_editors=[' and ' list_of_editors ' and '];
    editor={};
    for k=1:length(strfind(list_of_editors,' and '))-1;
      editor{k}=list_of_editors(strfind(list_of_editors,' and ')(k)+length(' and '):strfind(list_of_editors,' and ')(k+1)-1);
    endfor
    
    for k=1:length(editor)
      editor{k}=[editor{k}(strfind(editor{k},', ')+2:length(editor{k})) ' ' editor{k}(1:strfind(editor{k},', ')-1)];
    endfor
    
    if length(editor)==1;
      str_editor=['<br><b>Editor</b>: ' editor{1}];
    else
      str_editor=['<br><b>Editor</b>: '];
      for k=1:length(editor)
        if k<length(editor)-1
          str_editor=[str_editor editor{k} ', '];
        elseif k==length(editor)-1
          str_editor=[str_editor editor{k} ' and '];
        elseif k==length(editor)
          str_editor=[str_editor editor{k}];
        endif
        
      endfor
    endif
    
  else
    str_editor='';
  endif
  
  
  if strcmp(ref_type,'article')
    str_reference=[str_title str_author str_journal str_year str_doi str_arxivID];
  elseif strcmp(ref_type,'book')
    str_reference=[str_title str_author str_editor str_year str_series str_volume str_publisher str_doi str_arxivID];
  elseif strcmp(ref_type,'misc')
    str_reference=[str_title str_author str_year str_arxivID];
  elseif strcmp(ref_type,'incollection')
    str_reference=[str_title str_author str_booktitle str_editor str_year str_series str_volume str_publisher str_doi str_arxivID];
  elseif strcmp(ref_type,'inproceedings')
    str_reference=[str_title str_author str_booktitle str_editor str_year str_series str_volume str_publisher str_doi str_arxivID];
  elseif strcmp(ref_type,'phdthesis')
	str_reference=[str_title str_author str_type str_school str_year str_doi str_arxivID];
  endif
  
  str_reference=['<b>ID</b>: ' key '<br><br>' str_reference];
  reference=fopen(['HTML citations/' key '.html'],'w');
  fprintf(reference,str_reference);
  fclose(reference);
  
  clear property_name;
  clear property;
  clear j;
  clear list_of_authors;
  clear authors;
  
  waitbar(i/(length(entries)-1));
endfor

close(loadbar);