%Any specific changes to the code should be marked by 'SPECIFIC FOR THIS FILE'
%
%This function will convert a file 'latexfile.tex' to html
%This specific version is set to convert articles
%
%STYLE MANUAL
%
%--- General practices ---
%
%Avoid too many latex macros.
%
%The LaTeX class should be article, amsart, or similar, to ensure compatibility.
%
%The text can be separated into numbered or unnumbered sections and subsections. unnumbered (starred) subsubsections are supported. Chapters and parts are not supported.
%
%Sections will be broken up into different HTML files. A sidebar will have links to sections and to subsections.
%
%Avoid pos in-text.
%
%--- Counters and numbering ---
%
%Sections and subsections support counters. subsubsections do not.
%
%The section counter will be a single number. The subsection counter will have the form '<section>.<subsection>', where <section> and <subsection> are the corresponding counters for the section and subsection.
%
%The subsection counter will be reset at every new section.
%
%Content will be numbered with a single counter.
%
%Content which can be numbered consists of environments and equations.
%
%Equations should be numbered using the '\ntag' command.
%
%--- Environments ---
%
%Most environments are supported, both in starred and unstarred versions.
%
%Labels are also allowed. Usually, optional arguments will also be supported.
%
%The latex code for the environment should match the desired type. E.g. the LaTeX code for 'Theorem 3.2' should be '\begin{theorem}...\end{theorem}'. Code such as '\begin{theo}...\end{theo}' will create 'Theo 3.2' instead.
%
%Unnumbered environments should use the starred-ed version; \begin{theorem*}, \begin{definition*}, etc.
%
%Two additional types of environments are used: 'denv' and 'penv'. These are short for 'definition-style' and 'plain-style'. These environments need an additional argument to give them a custom name. In LaTeX, these are formatted with '\theoremstyle{definition}' and '\theoremstyle{plain}'. Starred versions are available as well. For example, '\begin{denv*}{Remark}...\end{denv*}' creates an unnumbered 'Remark' environment, which is formatted as a 'Definition'. These environments should be used for blocks of text which are to be only slightly pronounced, such as 'Remark', 'Terminology', 'Convention', etc. The corresponding HTML environments will be named and numbered accordingly, but their formatting will be different than that from Definitions, Proposition, etc.; Namely, these blocks will be less pronounced.
%
%--- Mathematical text---
%
%Use the starred (unnumbered) equation commands '\[...\]', '\begin{equation*}...\end{equation*}', '\begin{align*}...\end{align*}', but not the unstarred (numbered) ones. To number an equation, use \ntag.
%
%All environments and equations use the same counter. To number an equation, use the '\ntag' command.
%
%IMPORTANT: Use at most '\ntag' per equation environment. If you have a sequence of equalities and you need to refer to two or more of them, use explicit text such as 'the second inequality of (3.5)' instead.
%
%Mathematical environments allow labels.
%
%In mathematical text, the 'greater-than' and 'smaller-than' symbols ('>' and '<') will be substituted by the codes '\greaterthan' and '\smallerthan', to avoid compatibility issues with HTML.
%
%Most of text in mathematical mode will be completely ignored.
%
%new command, math operators, etc. should be defined in file 'src/latexcommands'. These may need to be slightly adapted.
%
%text inside math mode does not work very well.
%
%packages (as long as supported) can be loaded either by being added to 'src/html_head', under TeX: {extensions: [... , ... ,]} (preferred), or by using '\requirepackage{...}' inside a math environment (e.g. 'src/latexcommands')
%
%tikz is relatively supported. Whenever used, a tikzpicture should be the only element in its mathematical environment. Image Magick is required.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%WHAT THIS FUNCTION DOES
%
%1. The main latex file is loaded as a single text string.
%2. Every external file, loaded by an '\input{...}', is also loaded into the text string.
%3. The parts before '\begin{document}' and after '\end{document}' (including those) are discarded.

%IMPORTANT: You should adapt the code below and the 'latexcommands' source file accordingly to ensure MathJaX works correctly

%2. Every '\emph{...}' is converted into '<em>...</em>'.
%3. Every '\uline{...}' and $\underline{}$ is converted into '<u>...</u>'
%4. Every '\textbf{...}' is converted into '<b>...</b>'
%All '\[...\]' is converted into '\begin{equation*}\end{equation*}

function latextohtml(latex_file_input)
  
  original_filename = ['   ' latex_file_input];
  
  if strcmp(original_filename(length(original_filename)-3:length(original_filename)),'.tex')
    original_filename = latex_file_input(1:length(latex_file_input)-4);
  else
    original_filename = latex_file_input;
  endif
  
  file = fileread([original_filename '.tex']);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %first we input all files
  %IMPORTANT: There should be no commented-out '\input's
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  exp_to_verify = '\input{';
  pos=strfind(file,exp_to_verify);
  
  while length(pos)>0
    disp(['There are ' int2str(length(file)) ' characters and ' int2str(length(pos)) ' files to be input.'])
    
    open_brac = pos(1)+ length(exp_to_verify)-1;
    clos_brac = findclosingbrac(file,open_brac);
    file_to_input_name = ['   ' file(open_brac+1:clos_brac-1)];
    
    if strcmp(file_to_input_name(length(file_to_input_name)-3:length(file_to_input_name)),'.tex')
      file_to_input = fileread(file(open_brac+1:clos_brac-1));
    else
      file_to_input = fileread([file(open_brac+1:clos_brac-1) '.tex']);
    endif
    
    file = [file(1:pos(1)-1) ...
              file_to_input ...
              file(clos_brac+1:length(file))];
      
    pos=strfind(file,exp_to_verify);
  endwhile
  
  disp(['There are ' int2str(length(file)) ' characters.'])
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %remove comments
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp('Removing comments.')
  
  %first remove comments in line
  pos=strfind(file,[sprintf('\n') '%']);
  
  while length(pos)>0
	j=pos(1)+2;
    while 1-strcmp(file(j),sprintf('\n'))
      j=j+1;
    endwhile
    file=[file(1:pos(1)-1) file(j:length(file))];
    pos=strfind(file,[sprintf('\n') '%']);
  endwhile
	
  pos=strfind(file,'%');
  while length(pos)>0
    j=pos(1)+1;
    while 1-strcmp(file(j),sprintf('\n'))
      j=j+1;
    endwhile
    file=[file(1:pos(1)-1) file(j:length(file))];
	pos=strfind(file,'%');
  endwhile
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %remove '\maketitle'
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  file=strrep(file,'\maketitle','');
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %find the title
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  title='';
  exp_to_verify = '\title{';
  disp(['-----' sprintf('\n') 'Finding title'])
  
  pos=strfind(file,exp_to_verify);
  if length(pos)>0
    open_brac = pos(1) + length(exp_to_verify)-1;
    clos_brac = findclosingbrac(file,open_brac);
      
    title = file(open_brac+1:clos_brac-1);
    title=strrep(title,'\\','<br>');
  endif
  
  if length(title)>0
    disp(['The title is ' sprintf('''') title sprintf('''') '.'])
  else
    disp(['No title found.'])
  endif
  
  sidebar = ['<h1 class=' sprintf('''') 'sidebar-title' sprintf('''') '>' ...
            title ...
            '</h1>' sprintf('\n') ...
            '<h1 class=' sprintf('''') 'sidebar-section' sprintf('''') '><a href=' sprintf('''') original_filename '_front.html' sprintf('''') '>Front page</a></h1>'];
  char_to_verify = 1;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %author information should be given in src/authors. Adapt that file and the code below as necessary
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp(['-----' sprintf('\n') 'Finding authors'])
  author_file=fileread('src/authors');
  authors='';
  k=strfind(author_file,'<author>');
  p=strfind(author_file,'</author>');
  if length(k)>0
    disp('The authors are');
  else
    disp('No authors found.');
  endif
  
  while length(k)>0;
    
    name_start = strfind(author_file,'<name>')+length('<name>');
    name_end = strfind(author_file,'</name>')-1;
    name = author_file(name_start:name_end);
    
    email_start = strfind(author_file,'<e-mail>')+length('<e-mail>');
    email_end = strfind(author_file,'</e-mail>')-1;
    email = author_file(email_start:email_end);
    %below is to safeguard the e-mail from spam
    email = strrep(email,'@', ['<span style=' sprintf('''') 'display:none' sprintf('''') '>rand</span>&#64;']);
    
    institution_start = strfind(author_file,'<institution>')+length('<institution>');
    institution_end = strfind(author_file,'</institution>')-1;
    institution = author_file(institution_start:institution_end);
    
    support_start = strfind(author_file,'<support>')+length('<support>');
    support_end = strfind(author_file,'</support>')-1;
    support = author_file(support_start:support_end);
    
    authors=[authors ...
      sprintf('\n\n') ...
      '<div class=' sprintf('''') 'author' sprintf('''') '>' sprintf('\n') ...
      '<span class=' sprintf('''') 'authorname' sprintf('''') '>' name '</span> ' ...
      '(<span class=' sprintf('''') 'authoremail' sprintf('''') '>' email '</span>)<br>' ...
      '<span class=' sprintf('''') 'authorinstitution' sprintf('''') '>' institution '</span><br>' sprintf('\n') ...
      '<span class=' sprintf('''') 'authorsupport' sprintf('''') '>' support '</span></div>'];
    k(1)=[];
    disp([sprintf('\n') name ',' sprintf('\n') 'from' sprintf('\n') institution])
  endwhile
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %if the paper is published, add information to file 'src/published'
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  counter = 0;
  sec_num = 0;
  subsec_num = 0;
  
  %We will use a second counter to id all elements which are referenciable. This includes lists and unnumbered sections, which will be referenced to in HTML. The old ids (given by '\label{...' in LaTeX) will be stored in a cell array 'old_label'. Another cell array, 'new_label', will have the corresponding new id's at the same position. So whenever we have \ref{<label>} in LaTeX, the corresponding new label may be found via 'new_label(find(strcmp(old_label,<label>)))'.
  
  old_label={};
  new_label=[];
  alt_counter=0;
  
  
  %we also need to remember section names. All referenciable content will have the id given by alt_counter. We need to remember the name of the file where they are at. Just keep them in order. Similarly, we need to save how they will be referenced to
  
  sec_file={};
  ref_name ={};
  sec_filenames = {}; %not to confuse with sec_filename (w.o. s)
  %erase everything before '\begin{document}', and erase '\end{document}'
  file = file(strfind(file,'\begin{document}')+length('\begin{document}'): strfind(file,'\end{document}')-1);
   
  char_to_verify=1;
  announce=1;
  inparagraph=0;
  in_list_item=0;
  
  %a technical detail: lists should be separated from paragraphs
  file=strrep(file,'\begin{enumerate}',[sprintf('\n\n') '\begin{enumerate}']);
  file=strrep(file,'\end{enumerate}',['\end{enumerate}' sprintf('\n\n')]);
  file=strrep(file,'\begin{itemize}',[sprintf('\n\n') '\begin{itemize}']);
  file=strrep(file,'\end{itemize}',['\end{itemize}' sprintf('\n\n')]);
  file=strrep(file,'\item',[sprintf('\n\n') '\item' sprintf('\n\n')]);
  file=strrep(file,'\end',[sprintf('\n\n') '\end']);
  file=strrep(file,'\begin{abstract}',['\beginabstract' sprintf('\n\n')]);
  file=strrep(file,'\end{abstract}',[sprintf('\n') '\endabstract']);
  file=strrep(file,'$\Sigma$','&Sigma;');
  %remove '\qedhere's
  file=strrep(file,'\qedhere','');
  
  %we also remove the bibliography at the end
  pos=strfind(file,'\bibliographystyle{');
  while length(pos)>0
    open_brac=pos(1)+length('\bibliographystyle{')-1;
    clos_brac=findclosingbrac(file,open_brac);
    file=[file(1:pos(1)-1) file(clos_brac+1:length(file))];
    pos=strfind(file,'\bibliographystyle{');
  endwhile
  
  %we also remove the bibliography at the end
  pos=strfind(file,'\bibliography{');
  while length(pos)>0
    open_brac=pos(1)+length('\bibliography{')-1;
    clos_brac=findclosingbrac(file,open_brac);
    file=[file(1:pos(1)-1) file(clos_brac+1:length(file))];
    pos=strfind(file,'\bibliography{');
  endwhile
  
  disp(sprintf('-----\n'))
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %trim unnecessary whitespaces before and after newlines, which can be useful when typing latex code.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp(['Trimming unnecessary whitespaces at beggining and endings of lines.']);
  trimbar=waitbar(0,'Trimming whitespace...');
  
  while char_to_verify<length(file)
    if strcmp(file(char_to_verify),sprintf('\n')) && isstrprop(file(char_to_verify+1),'wspace') && (1-strcmp(file(char_to_verify+1),sprintf('\n')))
      file(char_to_verify+1)='';
    elseif char_to_verify>1 && strcmp(file(char_to_verify),sprintf('\n')) && isstrprop(file(char_to_verify-1),'wspace') && (1-strcmp(file(char_to_verify-1),sprintf('\n')))
      file(char_to_verify-1)='';
      char_to_verify=char_to_verify-1;
    else
      char_to_verify=char_to_verify+1;
    endif
    
    if char_to_verify/length(file)>announce/100
      waitbar(char_to_verify/length(file));
      announce=announce+1;
    endif
  endwhile
  close(trimbar);
  
  disp(['-----' sprintf('\n') 'Trimming complete.'])
  char_to_verify=1;
  announce=1;
  
  convertbar=waitbar(0,'Converting LaTeX to HTML...');
  disp(['-----' sprintf('\n') 'Converting LaTeX to HTML.'])
  
  sec_filename=[original_filename '_front.html'];
  
  while char_to_verify < length(file)
      
    %-----------------------------------------------------------------
    %First we check the in-text commands inside braces
    %-----------------------------------------------------------------
    
    %check for paragraph.
    exp_to_verify = sprintf('\n\n');
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      %delete all white spaces after these two new lines
      while (length(file)>char_to_verify+1) && (isstrprop(file(char_to_verify+length(exp_to_verify)),'wspace'))
            file(char_to_verify+2)='';
      endwhile
      
      if inparagraph
        file=[file(1:char_to_verify) '</p>' sprintf('\n') file(char_to_verify+1:length(file))];
        inparagraph=0;
        char_to_verify=char_to_verify+length('</p>')-1;
      elseif (1-inparagraph) && length(file)>char_to_verify+1 && ...
        (isstrprop(file(char_to_verify+2),'alphanum') || ...
          strcmp(file(char_to_verify+2),'$') || ...
          strcmp(file(char_to_verify+2:min(length(file),char_to_verify+2+length('\text')-1)),'\text') || ...
          strcmp(file(char_to_verify+2:min(length(file),char_to_verify+2+length('\emph')-1)),'\emph') || ...
          strcmp(file(char_to_verify+2:min(length(file),char_to_verify+2+length('\underline')-1)),'\underline') || ...
          strcmp(file(char_to_verify+2:min(length(file),char_to_verify+2+length('\uline')-1)),'\uline') || ...
          strcmp(file(char_to_verify+2:min(length(file),char_to_verify+2+length('\input')-1)),'\input') ...
          )
        file=[ file(1:char_to_verify) '<p>' sprintf('\n') file(char_to_verify+2:length(file))];
        inparagraph=1;
        char_to_verify=char_to_verify+1;        
      endif
      
    endif
    %
        
    
    
    
    %check if we are at a '$$'
    exp_to_verify = '$$';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      eq_close=char_to_verify+1+strfind(file(char_to_verify+2:length(file)),'$$')(1);
      
      file=[file(1:char_to_verify-1) '\[' file(char_to_verify+2:eq_close-1) '\]' file(eq_close+1:length(file))];
      
      char_to_verify=char_to_verify-1;
    endif
    %
    
    
    
    
    %check if we are at a '$'
    exp_to_verify = '$';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      closing_math=char_to_verify+1;
      
      while 1-strcmp(file(closing_math),'$')
        closing_math=closing_math+1;
      endwhile
      
      math=file(char_to_verify+1:closing_math-1);
      math=strrep(math,'<','\smallerthan ');
      math=strrep(math,'>','\greaterthan ');
      
      file=[file(1:char_to_verify)  math file(closing_math:length(file))];
      char_to_verify=char_to_verify+length(math)+2;
    endif
    %
    
    
    
    
    %check if we are at a '---'
    exp_to_verify = '---';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      file=[file(1:char_to_verify-1) '&#8212;' file(char_to_verify+length(exp_to_verify):length(file))];
      char_to_verify=char_to_verify+length('&#8212;')-1;
    endif
    %
    
    
    
    
    %check if we are at a '--'
    exp_to_verify = '--';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      file=[file(1:char_to_verify-1) '&#8210;' file(char_to_verify+length(exp_to_verify):length(file))];
      char_to_verify=char_to_verify+length('&#8210;')-1;
    endif
    %
    
    
    
    
    %check if we have a '\ ' in-text
    exp_to_verify = '\ ';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      file(char_to_verify)='';
    endif
    %
    
    
    
    
    %check if we have a '\ldots'
    exp_to_verify='\ldots';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      file=[file(1:char_to_verify-1) '&#8230;' file(char_to_verify+length(exp_to_verify):length(file))];
	  char_to_verify=char_to_verify+length(exp_to_verify)-1;
    endif
    %
    
    
    
    
	%check if we have a '\v{' (caron) in-text
    exp_to_verify='\v{';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      if strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)+1),'\v{a}')
        file=[file(1:char_to_verify-1) '&#462;' file(char_to_verify+length(exp_to_verify)+2:length(file))];
        char_to_verify=char_to_verify+length(exp_to_verify)+1;
      elseif strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)+1),'\v{c}')
        file=[file(1:char_to_verify-1) '&#269;' file(char_to_verify+length(exp_to_verify)+2:length(file))];
        char_to_verify=char_to_verify+length(exp_to_verify)+1;
      elseif strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)+1),'\v{e}')
        file=[file(1:char_to_verify-1) '&#283;' file(char_to_verify+length(exp_to_verify)+2:length(file))];
        char_to_verify=char_to_verify+length(exp_to_verify)+1;
      elseif strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)+1),'\v{i}')
        file=[file(1:char_to_verify-1) '&#464;' file(char_to_verify+length(exp_to_verify)+2:length(file))];
        char_to_verify=char_to_verify+length(exp_to_verify)+1;
      elseif strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)+1),'\v{o}')
        file=[file(1:char_to_verify-1) '&#466;' file(char_to_verify+length(exp_to_verify)+2:length(file))];
        char_to_verify=char_to_verify+length(exp_to_verify)+1;
      elseif strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)+1),'\v{s}')
        file=[file(1:char_to_verify-1) '&#353;' file(char_to_verify+length(exp_to_verify)+2:length(file))];
        char_to_verify=char_to_verify+length(exp_to_verify)+1;
      elseif strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)+1),'\v{u}')
        file=[file(1:char_to_verify-1) '&#468;' file(char_to_verify+length(exp_to_verify)+2:length(file))];
        char_to_verify=char_to_verify+length(exp_to_verify)+1;
      else
        input(['Unexpected caron near id ' int2str(id) '. Press any key to continue']);
        char_to_verify=char_to_verify+length(exp_to_verify);
      endif
    endif
    %
    
    
    
    
    %check if we are at a '\emph{'
    exp_to_verify = '\emph{';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      open_brac = char_to_verify+length(exp_to_verify)-1;
      clos_brac = findclosingbrac(file,open_brac);
      
      file = [file(1:char_to_verify-1) ...
              '<em>' ...
              file(open_brac+1:clos_brac-1) ...
              '</em>' ...
              file(clos_brac+1:length(file))];
      
      char_to_verify = char_to_verify + length('<em>')-1;
    endif
    %
    
    
    
    
    %let us check if we are at a '\textit{'
    exp_to_verify = '\textit{';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      open_brac = char_to_verify+length(exp_to_verify)-1;
      clos_brac = findclosingbrac(file,open_brac);
      
      file = [file(1:char_to_verify-1) ...
              '<i>' ...
              file(open_brac+1:clos_brac-1) ...
              '</i>' ...
              file(clos_brac+1:length(file))];
      
      char_to_verify = char_to_verify + length('<i>')-1;
    endif
    %
    
    
    
    
    %let us check if we are at a '\textbf{'
    exp_to_verify = '\textbf{';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      open_brac = char_to_verify+length(exp_to_verify)-1;
      clos_brac = findclosingbrac(file,open_brac);
      
      file = [file(1:char_to_verify-1) ...
              '<b>' ...
              file(open_brac+1:clos_brac-1) ...
              '</b>' ...
              file(clos_brac+1:length(file))];
      
      char_to_verify = char_to_verify + length('<i>')-1;
    endif
    %
    
    
    
    
    %let us check if we are at a '\underline{'
    exp_to_verify = '\underline{';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      open_brac = char_to_verify+length(exp_to_verify)-1;
      clos_brac = findclosingbrac(file,open_brac);
      
      file = [file(1:char_to_verify-1) ...
              '<u>' ...
              file(open_brac+1:clos_brac-1) ...
              '</u>' ...
              file(clos_brac+1:length(file))];
      
      char_to_verify = char_to_verify + length('<u>')-1;
    endif
    %
    
    
    
    
    %let us check if we are at a '\uline{'
    exp_to_verify = '\uline{';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      open_brac = char_to_verify+length(exp_to_verify)-1;
      clos_brac = findclosingbrac(file,open_brac);
      
      file = [file(1:char_to_verify-1) ...
              '<u>' ...
              file(open_brac+1:clos_brac-1) ...
              '</u>' ...
              file(clos_brac+1:length(file))];
      
      char_to_verify = char_to_verify + length('<u>')-1;
    endif
    %
    
    
    
    
    %let us check if we are at a '\textsubscript{'
    exp_to_verify = '\textsubscript{';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      open_brac = char_to_verify+length(exp_to_verify)-1;
      clos_brac = findclosingbrac(file,open_brac);
      
      file = [file(1:char_to_verify-1) ...
              '<sub>' ...
              file(open_brac+1:clos_brac-1) ...
              '</sub>' ...
              file(clos_brac+1:length(file))];
      
      char_to_verify = char_to_verify + length('<sub>')-1;
    endif
    %
    
    
    
    
    %let us check if we are at a '\textsuperscript{'
    exp_to_verify = '\textsuperscript{';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      open_brac = char_to_verify+length(exp_to_verify)-1;
      clos_brac = findclosingbrac(file,open_brac);
      
      file = [file(1:char_to_verify-1) ...
              '<sup>' ...
              file(open_brac+1:clos_brac-1) ...
              '</sup>' ...
              file(clos_brac+1:length(file))];
      
      char_to_verify = char_to_verify + length('<sup>')-1;
    endif
    %
    
    
    
    
    %let us check if we are at a `` (beggining double quote)
    exp_to_verify = '``';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      file = [file(1:char_to_verify-1) ...
              '<span>&#8220;</span>' ...
              file(char_to_verify+length(exp_to_verify):length(file))];
      
      char_to_verify = char_to_verify + length('<span>&#8220;</span>')-1;
    endif
    %
    
    
    
    
    %let us check if we are at a '' (end double quote)
    exp_to_verify = [sprintf('''') sprintf('''')];
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      file = [file(1:char_to_verify-1) ...
              '<span>&#8221;</span>' ...
              file(char_to_verify+length(exp_to_verify):length(file))];
      
      char_to_verify = char_to_verify + length('<span>&#8221;</span>')-1;
    endif
    %
    
    
    
    
    %check if we are at a '\section'
    exp_to_verify = '\section';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      %this is a referenciable element
      alt_counter=alt_counter+1;
      str_id = [' id=' sprintf('''') int2str(alt_counter) sprintf('''')];
      
      %verify if it has a counter or not
      if strcmp(file(char_to_verify+length(exp_to_verify)),'*');
        str_sec_num='';
        open_brac=char_to_verify+length('\section*{')-1;
      else
        sec_num = sec_num+1;
        str_sec_num = [int2str(sec_num) '. '];
        %reset subsection and counter
        subsec_num = 0;
        counter=0;
        open_brac=char_to_verify+length('\section{')-1;
      endif
            
      clos_brac = findclosingbrac(file,open_brac);
      
      section_title=file(open_brac+1:clos_brac-1);
      
      label_clos_brac=clos_brac;
      
      %let us look for a section label
      if strcmp(file(clos_brac+1:clos_brac+length('\label{')),'\label{')
        
        label_open_brac = clos_brac+length('\label{');
        label_clos_brac = findclosingbrac(file,label_open_brac);
        
        label=file(label_open_brac+1:label_clos_brac-1);
        
        old_label{length(old_label)+1}= label;
        new_label(length(new_label)+1)= alt_counter;
      endif
      
      %this section now has a unique label.
      sec_filename=[original_filename '_' int2str(sec_num)];
      if strcmp(file(char_to_verify+length('\section*')-1),'*')
        sec_filename = [sec_filename '_' int2str(alt_counter)];
      endif
      
      sec_filenames{length(sec_filenames)+1}=sec_filename;
      
      %save this section name
      sec_file{alt_counter}=sec_filename;
      
      %update sidebar
      sidebar=[sidebar sprintf('\n') ...
              '<hr>' sprintf('\n')' ...
              '<h1 class=' sprintf('''') 'sidebar-section' sprintf('''') '>' ...
              '<a href=' sprintf('''') sec_filename '.html' sprintf('''') '>' ...
              str_sec_num section_title ...
              '</a></h1>'];
              
      file = [file(1:char_to_verify-1) ...
              '<h2 class=' sprintf('''') 'section' sprintf('''') str_id '>' ...
              str_sec_num section_title ...
              '</h2>' ...
              file(label_clos_brac+1:length(file))];
        
      char_to_verify = char_to_verify + length(['<h2 class=' sprintf('''') 'section' sprintf('''') str_id '>' str_sec_num]) - 1;
      
      %if we have a reference to this section, we will have a link to the div. Not a problem, necessarily, but slightly different from what happens when we click the link in the sidebar
      sec_file{alt_counter}= sec_filename;
      %the ref_name will be the section number, if it is numbered, or the section title followed by '(unnumbered)' if not.
      if length(str_sec_num)==0
        ref_name{alt_counter}=[sprintf('''') section_title sprintf('''') ' (unnumbered)'];
      else
        ref_name{alt_counter}=int2str(sec_num);
      endif
      
    endif
    %
    
    
    
    
    %let us check if we are at a '\subsection'
    exp_to_verify = '\subsection';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      %this is a referenciable element
      alt_counter=alt_counter+1;
      str_id = [' id=' sprintf('''') int2str(alt_counter) sprintf('''')];
      sec_file{alt_counter}=sec_filename;
      %verify if it has a counter or not
      if strcmp(file(char_to_verify+length(exp_to_verify)),'*');
        str_subsec_num='';
        open_brac=char_to_verify+length('\subsection*{')-1;
      else
        subsec_num = subsec_num+1;
        str_subsec_num = [int2str(sec_num) '.' int2str(subsec_num) '. '];
        
        open_brac=char_to_verify+length('\subsection{')-1;
      endif
            
      clos_brac = findclosingbrac(file,open_brac);
      
      subsection_title=file(open_brac+1:clos_brac-1);
      
      label_clos_brac=clos_brac;
      
      %let us look for a subsection label
      if strcmp(file(clos_brac+1:clos_brac+length('\label{')),'\label{')
        
        label_open_brac = clos_brac+length('\label{');
        label_clos_brac = findclosingbrac(file,label_open_brac);
        
        old_label{length(old_label)+1} = file(label_open_brac+1:label_clos_brac-1);
        new_label(length(new_label)+1) = alt_counter;
      endif
      
      %update sidebar
      sidebar=[sidebar sprintf('\n') ...
              '<h2 class=' sprintf('''') 'sidebar-subsection' sprintf('''') '>' ...
              '<a href=' sprintf('''') sec_filename '.html#' int2str(alt_counter) sprintf('''') '>' ...
              str_subsec_num subsection_title ...
              '</a></h2>'];
              
      file = [file(1:char_to_verify-1) ...
              '<h3 class=' sprintf('''') 'subsection' sprintf('''') str_id '>' ...
              str_subsec_num subsection_title ...
              '</h3>' ...
              file(label_clos_brac+1:length(file))];
        
      char_to_verify = char_to_verify + length(['<h3 class=' sprintf('''') 'subsection' sprintf('''') str_id '>' str_subsec_num]) - 1;
      
      %ref_name as section
      if length(str_subsec_num)==0
        ref_name{alt_counter}=[sprintf('''') subsection_title sprintf('''') ' (unnumbered)'];
      else
        ref_name{alt_counter}=[int2str(sec_num) '.' int2str(subsec_num)];
      endif
    endif
    %
    
    
    
    
    %let us check if we are at a '\subsubsection*{'
    exp_to_verify = '\subsubsection*{';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      %this is a referenciable element
      alt_counter=alt_counter+1;
      str_id = [' id=' sprintf('''') int2str(alt_counter) sprintf('''')];
      sec_file{alt_counter}=sec_filename;
      
      open_brac = char_to_verify+length(exp_to_verify)-1;
      clos_brac = findclosingbrac(file,open_brac);
      
      subsubsection_title=file(open_brac+1:clos_brac-1);
      
      file = [file(1:char_to_verify-1) ...
              '<h4 class=' sprintf('''') 'subsubsection' sprintf('''') str_id '>' ...
              subsubsection_title ...
              '</h4>' ...
              file(clos_brac+1:length(file))];
        
      char_to_verify = char_to_verify + length(['<h4 class=' sprintf('''') 'subsubsection' sprintf('''') str_id '>']) - 1;
      
      %ref_name as unnumbered section
        ref_name{alt_counter}=[sprintf('''') subsubsection_title sprintf('''') ' (unnumbered)'];
      
    endif
    %
    
    
    
    
    %let us check if we are at a '\[...\]'. 
    exp_to_verify = '\[';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      %this is a referenciable element
      alt_counter=alt_counter+1;
      str_id = [' id=' sprintf('''') int2str(alt_counter) sprintf('''')];
      sec_file{alt_counter}=sec_filename;
      
      %We need to find the closing part of the equation
      close_eq=char_to_verify+length(exp_to_verify);
      while 1-strcmp(file(close_eq:close_eq+length('\]')-1),'\]')
        close_eq=close_eq+1;
      endwhile
      
      %check if there is an ntag.
      ntag_start=strfind(file(char_to_verify+length(exp_to_verify):close_eq-1),'\ntag');
      if length(ntag_start)>0
        ntag_start=ntag_start+char_to_verify+length(exp_to_verify)-1;
        counter=counter+1;
        %rewrite this ntag as tag
        file = [file(1:ntag_start-1) ...
                  '\tag{' int2str(sec_num) '.' int2str(counter) '}' ...
                  file(ntag_start+length('\ntag'):length(file))];
          
        %since we rewrote the math environment, we need to update close_eq. The new one will be larger, so we can just continue from the current position
        while 1-strcmp(file(close_eq:close_eq+length('\]')-1),'\]')
          close_eq=close_eq+1;
        endwhile
      endif
      
      %look for an equation label
      label_open_brac=strfind(file(char_to_verify+length(exp_to_verify):close_eq-1),'\label{');
      if length(label_open_brac)>0
        label_open_brac=label_open_brac+char_to_verify+length(exp_to_verify)-1+length('\label{')-1;
        label_clos_brac = findclosingbrac(file,label_open_brac);
        
        old_label{length(old_label)+1}=file(label_open_brac+1:label_clos_brac-1);
        new_label(length(new_label)+1)=alt_counter;
          
        %remove the label
        file=[file(1:label_open_brac-length('\label{')) file(label_clos_brac+1:length(file))];
          
        %update close_eq
        close_eq=char_to_verify+length(exp_to_verify);
        while 1-strcmp(file(close_eq:close_eq+length('\]')-1),'\]')
          close_eq=close_eq+1;
        endwhile
      endif
      
      %We need to remove possible empty lines after \[ and before \]. For this, we simply erase all newlines and space (whitespaces) in those positions.
      
      while isstrprop(file(char_to_verify+length(exp_to_verify)),'wspace')
        file=[file(1:char_to_verify+length(exp_to_verify)-1) file(char_to_verify+length(exp_to_verify)+1:length(file))];
        close_eq=close_eq-1;
      endwhile
      
      while isstrprop(file(close_eq-1),'wspace')
        file=[file(1:close_eq-2) file(close_eq:length(file))];
        close_eq=close_eq-1;
      endwhile
      
      math=file(char_to_verify+length(exp_to_verify):close_eq-1);
      math=strrep(math,'<','\smallerthan ');
      math=strrep(math,'>','\greaterthan ');
      
      file = [file(1:char_to_verify-1) ...
        '<div class=' sprintf('''') 'equation' sprintf('''') str_id '>' sprintf('\n')...
        '\begin{equation*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{equation*}' sprintf('\n') ...
        '</div>' ...
        file(close_eq+length('\]'):length(file))];
      
      %skip the whole math to keep it unchanged; the easist way is simply to see where the div above is closed. Even if 'file' was changes, we just care about lengths, so it doesn't matter.
      char_to_verify = length([file(1:char_to_verify-1) ...
        '<div class=' sprintf('''') 'equation' sprintf('''') str_id '>' sprintf('\n')...
        '\begin{equation*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{equation*}' sprintf('\n') ...
        '</div>']);
        
      %ref_name
      if length(ntag_start)==0
        ref_name{alt_counter}='(unnumbered equation)';
      else
        ref_name{alt_counter}=[int2str(sec_num) '.' int2str(counter)];
      endif
    endif
    %
    
    
    
    
    %check if we are at a '\begin{equation*}...\end{equation*}'. 
    exp_to_verify = '\begin{equation*}';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      %this is a referenciable element
      alt_counter=alt_counter+1;
      str_id = [' id=' sprintf('''') int2str(alt_counter) sprintf('''')];
      sec_file{alt_counter}=sec_filename;
      
      %We need to find the closing part of the equation
      close_eq=char_to_verify+length(exp_to_verify);
      while 1-strcmp(file(close_eq:close_eq+length('\end{equation*}')-1),'\end{equation*}')
        close_eq=close_eq+1;
      endwhile
      
      %check if there is an ntag.
      ntag_start=strfind(file(char_to_verify+length(exp_to_verify):close_eq-1),'\ntag');
      if length(ntag_start)>0
        ntag_start=ntag_start+char_to_verify+length(exp_to_verify)-1;
        counter=counter+1;
        %rewrite this ntag as tag
        file = [file(1:ntag_start-1) ...
                  '\tag{' int2str(sec_num) '.' int2str(counter) '}' ...
                  file(ntag_start+length('\ntag'):length(file))];
          
        %since we rewrote the math environment, we need to update close_eq. The new one will be larger, so we can just continue from the current position
        while 1-strcmp(file(close_eq:close_eq+length('\end{equation*}')-1),'\end{equation*}')
          close_eq=close_eq+1;
        endwhile
      endif
      
      label='';
      
      %look for an equation label
      label_open_brac=strfind(file(char_to_verify+length(exp_to_verify):close_eq-1),'\label');
      if length(label_open_brac)>0
        label_open_brac=label_open_brac+char_to_verify+length(exp_to_verify)-1+length('\label{')-1;
        label_clos_brac = findclosingbrac(file,label_open_brac);
        
        old_label{length(old_label)+1}=file(label_open_brac+1:label_clos_brac-1);
        new_label(length(new_label)+1)=alt_counter;
          
        %remove the label
        file=[file(1:label_open_brac-length('\label{')) file(label_clos_brac+1:length(file))];
          
        %update close_eq
        close_eq=char_to_verify+length(exp_to_verify);
        while 1-strcmp(file(close_eq:close_eq+length('\end{equation*}')-1),'\end{equation*}')
          close_eq=close_eq+1;
        endwhile
      endif
      
      %We need to remove possible empty lines after \[ and before \]. For this, we simply erase all newlines and space (whitespaces) in those positions.
      
      while isstrprop(file(char_to_verify+length(exp_to_verify)),'wspace')
        file=[file(1:char_to_verify+length(exp_to_verify)-1) file(char_to_verify+length(exp_to_verify)+1:length(file))];
        close_eq=close_eq-1;
      endwhile
      
      while isstrprop(file(close_eq-1),'wspace')
        file=[file(1:close_eq-2) file(close_eq:length(file))];
        close_eq=close_eq-1;
      endwhile
      
      math=file(char_to_verify+length(exp_to_verify):close_eq-1);
      math=strrep(math,'<','\smallerthan ');
      math=strrep(math,'>','\greaterthan ');
      
      file = [file(1:char_to_verify-1) ...
        '<div class=' sprintf('''') 'equation' sprintf('''') str_id '>' sprintf('\n')...
        '\begin{equation*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{equation*}' sprintf('\n') ...
        '</div>' ...
        file(close_eq+length('\end{equation*}'):length(file))];
      
      %skip the whole math to keep it unchanged; the easist way is simply to see where the div above is closed. Even if 'file' was changes, we just care about lengths, so it doesn't matter.
      char_to_verify = length([file(1:char_to_verify-1) ...
        '<div class=' sprintf('''') 'equation' sprintf('''') str_id '>' sprintf('\n')...
        '\begin{equation*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{equation*}' sprintf('\n') ...
        '</div>']);
      
      %ref_name
      if length(ntag_start)==0
        ref_name{alt_counter}='(unnumbered equation)';
      else
        ref_name{alt_counter}=[int2str(sec_num) '.' int2str(counter)];
      endif
    endif
    %
    
    
    
    
    %check if we are at a '\begin{align*}...\end{align*}'. 
    exp_to_verify = '\begin{align*}';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      %this is a referenciable element
      alt_counter=alt_counter+1;
      str_id = [' id=' sprintf('''') int2str(alt_counter) sprintf('''')];
      sec_file{alt_counter}=sec_filename;
      
      %We need to find the closing part of the equation
      close_eq=char_to_verify+length(exp_to_verify);
      while 1-strcmp(file(close_eq:close_eq+length('\end{align*}')-1),'\end{align*}')
        close_eq=close_eq+1;
      endwhile
      
      %check if there is an ntag.
      ntag_start=strfind(file(char_to_verify+length(exp_to_verify):close_eq-1),'\ntag');
      if length(ntag_start)>0
        ntag_start=ntag_start+char_to_verify+length(exp_to_verify)-1;
        counter=counter+1;
        %rewrite this ntag as tag
        file = [file(1:ntag_start-1) ...
                  '\tag{' int2str(sec_num) '.' int2str(counter) '}' ...
                  file(ntag_start+length('\ntag'):length(file))];
          
        %since we rewrote the math environment, we need to update close_eq. The new one will be larger, so we can just continue from the current position
        while 1-strcmp(file(close_eq:close_eq+length('\end{align*}')-1),'\end{align*}')
          close_eq=close_eq+1;
        endwhile
      endif
      
      label='';
      
      %look for an equation label
      label_open_brac=strfind(file(char_to_verify+length(exp_to_verify):close_eq-1),'\label');
      if length(label_open_brac)>0
        label_open_brac=label_open_brac+char_to_verify+length(exp_to_verify)-1+length('\label{')-1;
        label_clos_brac = findclosingbrac(file,label_open_brac);
        
        old_label{length(old_label)+1}=file(label_open_brac+1:label_clos_brac-1);
        new_label(length(new_label)+1)=alt_counter;
          
        %remove the label
        file=[file(1:label_open_brac-length('\label{')) file(label_clos_brac+1:length(file))];
          
        %update close_eq
        close_eq=char_to_verify+length(exp_to_verify);
        while 1-strcmp(file(close_eq:close_eq+length('\end{align*}')-1),'\end{align*}')
          close_eq=close_eq+1;
        endwhile
      endif
      
      %We need to remove possible empty lines after \[ and before \]. For this, we simply erase all newlines and space (whitespaces) in those positions.
      
      while isstrprop(file(char_to_verify+length(exp_to_verify)),'wspace')
        file=[file(1:char_to_verify+length(exp_to_verify)-1) file(char_to_verify+length(exp_to_verify)+1:length(file))];
        close_eq=close_eq-1;
      endwhile
      
      while isstrprop(file(close_eq-1),'wspace')
        file=[file(1:close_eq-2) file(close_eq:length(file))];
        close_eq=close_eq-1;
      endwhile
      
      math=file(char_to_verify+length(exp_to_verify):close_eq-1);
      math=strrep(math,'<','\smallerthan ');
      math=strrep(math,'>','\greaterthan ');
      
      file = [file(1:char_to_verify-1) ...
        '<div class=' sprintf('''') 'equation' sprintf('''') str_id '>' sprintf('\n')...
        '\begin{align*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{align*}' sprintf('\n') ...
        '</div>' ...
        file(close_eq+length('\end{align*}'):length(file))];
      
      %skip the whole math to keep it unchanged; the easist way is simply to see where the div above is closed. Even if 'file' was changes, we just care about lengths, so it doesn't matter.
      char_to_verify = length([file(1:char_to_verify-1) ...
        '<div class=' sprintf('''') 'equation' sprintf('''') str_id '>' sprintf('\n')...
        '\begin{align*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{align*}' sprintf('\n') ...
        '</div>']);
      
      %ref_name
      if length(ntag_start)==0
        ref_name{alt_counter}='(unnumbered equation)';
      else
        ref_name{alt_counter}=[int2str(sec_num) '.' int2str(counter)];
      endif
    endif
    %
    
    
    
    
    %let us check if we are at a '\begin{enumerate}'
    exp_to_verify = '\begin{enumerate}';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      %let us check if there are custom labels. The labels should be of the form '(\alph*)', which yields '(a),(b),(c)',...;  '\Roman*.', which yields I., II., ..., or even something like 'P-\roman*' which yields 'P-i, P-ii, P-iii',...
      list_class='';
      list_css='';
      label_close=char_to_verify+length('\begin{enumerate}')-1;
      
      if strcmp(file(char_to_verify+length(exp_to_verify):char_to_verify+length(exp_to_verify)+length('[label=')-1),'[label=')
        
        %custom lists will use our 'alt-counter' for a custom class
        alt_counter=alt_counter+1;
        list_class=[' class=' sprintf('''') 'alt altlist' int2str(alt_counter) sprintf('''')];
        
        label_open = char_to_verify+length(exp_to_verify);
        label_close = findclosingbrac(file,label_open);
        
        j=label_open+length('[label=');
        while j<label_close
          if strcmp(file(j:j+length('\alph*')-1),'\alph*')
            list_css=[list_css ' counter(listcounter,lower-alpha)' ];
            j=j+length('\alph*');
          elseif strcmp(file(j:j+length('&Sigma;')-1),'&Sigma;')
            list_css=[list_css ' ' sprintf('''') '\03A3' sprintf('''') ];
            j=j+length('&Sigma;');
          elseif strcmp(file(j:j+length('\Alph*')-1),'\Alph*')
            list_css=[list_css ' counter(listcounter,upper-alpha)' ];
            j=j+length('\Alph*');
          elseif strcmp(file(j:j+length('\roman*')-1),'\roman*')
            list_css=[list_css ' counter(listcounter,lower-roman)' ];
            j=j+length('\roman*');
          elseif strcmp(file(j:j+length('\Roman*')-1),'\Roman*')
            list_css=[list_css ' counter(listcounter,upper-roman)' ];
            j=j+length('\Roman*');
          elseif strcmp(file(j:j+length('\arabic*')-1),'\arabic*')
            list_css=[list_css ' counter(listcounter)' ];
            j=j+length('\arabic*');
          elseif strcmp(file(j),'\')
            disp(['WARNING: A list close to id ' int2str(alt_counter) ' has a LaTeX macro inside its label with ' sprintf('''') '\' sprintf('''') '. This is not supported.'])
            j=j+1;            
          else
            list_css=[list_css ' ' sprintf('''') file(j) sprintf('''')];
            j=j+1;
          endif
        endwhile
        
        list_css = ['<style>' ...
              'ol.altlist' int2str(alt_counter) ' > li:before {' sprintf('\n') ...
                'content: ' list_css ';' sprintf('\n') ...
              '}' sprintf('\n') ...
              '</style>' sprintf('\n')];
      endif
      
      file=[file(1:char_to_verify-1) ...
      list_css ...
      '<ol' list_class '>'  file(label_close+1:length(file))];
      
      char_to_verify=char_to_verify+length([list_css '<ol' list_class '>'])-1;
    endif
    %
    
    
    
    
    %check '\begin{itemize}'
    exp_to_verify = '\begin{itemize}';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      file=[file(1:char_to_verify-1) '<ul>' file(char_to_verify+length(exp_to_verify):length(file))];
      
      char_to_verify=char_to_verify+length('<ul>')-1;
    endif
    
    
    
    
    %check if we are at a '\item'. Note that we need to add a bunch of newlines to deal with paragraphs in items.    
    exp_to_verify = '\item';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      %referenciable element
      alt_counter=alt_counter+1;
      str_id = [' id=' sprintf('''') int2str(alt_counter) sprintf('''')];
      sec_file{alt_counter}=sec_filename;
      
      %look for label
      label_clos_brac=char_to_verify+length(exp_to_verify)-1;
      
      %remember: we added two newlines after \item, so we skip those by adding a +2 below
      if strcmp(file(char_to_verify+length(exp_to_verify)+2:char_to_verify+length(exp_to_verify)+length('\label{')-1+2),'\label{')
        label_open_brac=char_to_verify+length(exp_to_verify)+length('\label{')-1+2;
        label_clos_brac=findclosingbrac(file,label_open_brac);
        
        old_label{length(old_label)+1} = file(label_open_brac+1:label_clos_brac-1);
        new_label(length(new_label)+1) = alt_counter;
      endif
      
      if in_list_item
        file=[file(1:char_to_verify-1) ...
          '</li>' sprintf('\n\n') ...
          '<li' str_id '>' sprintf('\n\n') ...
          file(label_clos_brac+1:length(file))];
          
        char_to_verify=char_to_verify+length(['</li>' sprintf('\n\n') '<li' str_id '>'])-1;
        
      else
        in_list_item=1;
        file=[file(1:char_to_verify-1) ...
          '<li' str_id '>' sprintf('\n\n') ...
          file(label_clos_brac+1:length(file))];
        
        char_to_verify=char_to_verify+length(['<li' str_id '>'])-1;
      endif
      
      %ref_name
      if label_clos_brac==char_to_verify+length(exp_to_verify)-1 %unlabelled
        ref_name{alt_counter}='unlabelled (item)';
      else
        ref_name{alt_counter}='(item)';
      endif
    endif
    %
    
    
    
    
    %check if we are at a '\end{enumerate}'
    exp_to_verify = '\end{enumerate}';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      in_list_item=0;
      
      file=[file(1:char_to_verify-1) '</li>' sprintf('\n') ...
      '</ol>' file(char_to_verify+length('\end{enumerate}'):length(file))];
      
      char_to_verify=char_to_verify+length('</ol>')-1;
    endif
    %
    
    
    
    
    %check if we are at a '\end{itemize}'
    exp_to_verify = '\end{itemize}';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      in_list_item=0;
      
      file=[file(1:char_to_verify-1) '</li>' sprintf('\n') '</ul>' file(char_to_verify+length('\end{itemize}'):length(file))];
      
      char_to_verify=char_to_verify+length('</ul>')-1;
    endif
    %
    
    
    
    
    %check if we are at a 'denv' or 'denv*'
    exp_to_verify = '\begin{denv';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify) 
      
      %referenciable element
      alt_counter=alt_counter+1;
      str_id = [' id=' sprintf('''') int2str(alt_counter) sprintf('''')];
      sec_file{alt_counter}=sec_filename;
      
      envtype='alt';
      
      denv_open_brac = char_to_verify+length('\begin{')-1;
      denv_clos_brac = findclosingbrac(file,denv_open_brac);      
      
      envtype_open_brac= denv_clos_brac+1;
      envtype_clos_brac=findclosingbrac(file,envtype_open_brac);
      
      %anything between those two is the environment identifier
      envidentifier=file(envtype_open_brac+1:envtype_clos_brac-1);
      
      %check if the environment is numbered or not, and update the counter and create the correct string for the counter if appropriate
      if strcmp(file(denv_clos_brac-1),'*')
        numbered_env=0;
        str_counter='';
      else
        numbered_env=1;
        counter=counter+1;
        str_counter=[' <span class=' sprintf('''') 'envcounter' sprintf('''') '>'  ...
        int2str(sec_num) '.' int2str(counter) '</span>'];
      endif
      
      %look for the label
      label_clos_brac=envtype_clos_brac;
      
      if length(file)>envtype_clos_brac+length('\label{')-1 && ...
        strcmp(file(envtype_clos_brac+1:envtype_clos_brac+length('\label{')),'\label{')
        
        label_open_brac=envtype_clos_brac+length('\label{');
        label_clos_brac=findclosingbrac(file,label_open_brac);
        
        old_label{length(old_label)+1}=file(label_open_brac+1:label_clos_brac-1);
        new_label(length(new_label)+1)=alt_counter;
      endif
      
      %Now the corresponding HTML code
      htmlenv= [...
        '<div class=' sprintf('''') envtype sprintf('''') str_id sprintf('>\n') ...
        '<span class=' sprintf('''') 'envidentifier' sprintf('''') '>' envidentifier '</span>' str_counter];
      
      %it is nice to add the number which appears in the page as a comment
      if numbered_env
        htmlenv=['<!-- ' int2str(sec_num) '.' int2str(counter) ' -->' ...
                sprintf('\n') htmlenv ];
      endif
      
      %let us simply keep the parts before the i-th position, the rewritten environment, and whatever's after the environment has ended. Add newlines for paragraph
      
      file = [file(1:char_to_verify-1) ...
              htmlenv sprintf('\n\n') ...
              file(label_clos_brac+1:length(file))];
      
      %let us skip the characters we added; notice that we add 1 at the end of the 'while'
      char_to_verify=char_to_verify+length(htmlenv)-1;
      
      %ref_name
      if length(str_counter)==0
        ref_name{alt_counter}=['unnumbered ' envidentifier];
      else
        ref_name{alt_counter}=[int2str(sec_num) '.' int2str(counter)];
      endif

    endif
    %
    
    
    
    %let us check if we are at a '\begin{proof}'
    exp_to_verify = '\begin{proof}';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify) 
      
      %referenciable
      alt_counter=alt_counter+1;
      str_id=[' id=' sprintf('''') int2str(alt_counter) sprintf('''')];
      sec_file{alt_counter}=sec_filename;
      
      envtype_open_brac=char_to_verify+length('\begin{')-1;
      envtype_clos_brac=findclosingbrac(file,envtype_open_brac);
      
      envtype='proof';
    
      %check if there is an optional argument.
      if strcmp(file(envtype_clos_brac+1),'[')
        oparg_open_brac=envtype_clos_brac+1;
        oparg_clos_brac=findclosingbrac(file,oparg_open_brac);
        
        %erase braces right inside the optional argument, which appear sometimes (e.g. when making citations with optional arguments);
        while strcmp(file(oparg_open_brac+1),'{') && strcmp(file(oparg_clos_brac-1),'}')
          file(oparg_clos_brac-1)=[];
          file(oparg_open_brac+1)=[];
          oparg_clos_brac=oparg_clos_brac-2;
        endwhile
        
        %the optional argument will be the new envidentifier
        envidentifier=file(oparg_open_brac+1:oparg_clos_brac-1);
      else
        oparg_clos_brac=envtype_clos_brac;
        envidentifier='Proof';
      endif
      
            %look for the label
      if length(file)>oparg_clos_brac+length('\label{')-1 && ...
        strcmp(file(oparg_clos_brac+1:oparg_clos_brac+length('\label{')),'\label{')
        
        label_open_brac=oparg_clos_brac+length('\label{');
        label_clos_brac=findclosingbrac(file,label_open_brac);
        
        old_label{length(old_label)+1}=file(label_open_brac+1:label_clos_brac-1);
        new_label(length(new_label)+1)=alt_counter;
      else
        label_clos_brac=oparg_clos_brac;
      endif
      
      %Now the corresponding HTML code
      
      htmlenv= ['<div class=' sprintf('''') envtype sprintf('''') str_id sprintf('>\n') ...
      '<span class=' sprintf('''') 'envidentifier' sprintf('''') '>' envidentifier '</span>.'];
      
      %let us simply keep the parts before the i-th position, the rewritten environment, and whatever's after the environment has ended. New lines for paragraph
      
      file=[file(1:char_to_verify-1) htmlenv sprintf('\n\n') file(label_clos_brac+1:length(file))];
      
      %let us skip the characters we added;
      char_to_verify=char_to_verify+length(htmlenv)-1;
      
      %ref_name

      ref_name{alt_counter}=['unnumbered' envidentifier];
      
    endif
    %
    
    %let us check if we are at any other environment
    exp_to_verify = '\begin{';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify) 
      
      %referenciable
      alt_counter=alt_counter+1;
      str_id=[' id=' sprintf('''') int2str(alt_counter) sprintf('''')];
      sec_file{alt_counter}=sec_filename;
      
      envtype_open_brac=char_to_verify+length('\begin{')-1;
      envtype_clos_brac=findclosingbrac(file,envtype_open_brac);
      
      %anything between those two is the environment type. This might have a star.
      envtype=file(envtype_open_brac+1:envtype_clos_brac-1);
    
      %check if there is an optional argument.
      if strcmp(file(envtype_clos_brac+1),'[')
        oparg_open_brac=envtype_clos_brac+1;
        oparg_clos_brac=findclosingbrac(file,oparg_open_brac);
        
        %erase braces right inside the optional argument, which appear sometimes (e.g. when making citations with optional arguments);
        while strcmp(file(oparg_open_brac+1),'{') && strcmp(file(oparg_clos_brac-1),'}')
          file(oparg_clos_brac-1)=[];
          file(oparg_open_brac+1)=[];
          oparg_clos_brac=oparg_clos_brac-2;
        endwhile
        
        %save optional argument
        oparg=[' <span class=' sprintf('''') 'envop' sprintf('''') '>(' file(oparg_open_brac+1:oparg_clos_brac-1) ')</span>'];
      else
        oparg_clos_brac=envtype_clos_brac;
        oparg='';
      endif
      
      %check if the environment is numbered or not, correct the envtype, and update the counter and create the correct string for the counter if appropriate
      if strcmp(envtype(length(envtype)),'*')
        numbered_env=0;
        envtype=envtype(1:length(envtype)-1);
        str_counter='';
      else
        numbered_env=1;
        counter=counter+1;
        str_counter=[' <span class=' sprintf('''') 'envcounter' sprintf('''') '>'  ...
          int2str(sec_num) '.' int2str(counter) '</span>'];
      endif
      
      %look for the label
      if length(file)>oparg_clos_brac+length('\label{')-1 && ...
        strcmp(file(oparg_clos_brac+1:oparg_clos_brac+length('\label{')),'\label{')
        
        label_open_brac=oparg_clos_brac+length('\label{');
        label_clos_brac=findclosingbrac(file,label_open_brac);
        
        old_label{length(old_label)+1}=file(label_open_brac+1:label_clos_brac-1);
        new_label(length(new_label)+1)=alt_counter;
      else
        label_clos_brac=oparg_clos_brac;
      endif
      
      %Now the corresponding HTML code
      envidentifier=[upper(envtype(1)) envtype(2:length(envtype))];
      
      htmlenv= ['<div class=' sprintf('''') envtype sprintf('''') str_id sprintf('>\n') ...
      '<span class=' sprintf('''') 'envidentifier' sprintf('''') '>' envidentifier '</span>' str_counter oparg '.'];
      
      if numbered_env
        htmlenv=['<!-- ' int2str(sec_num) '.' int2str(counter) ' -->' ...
                sprintf('\n') htmlenv ];
      endif
      
      %let us simply keep the parts before the i-th position, the rewritten environment, and whatever's after the environment has ended. New lines for paragraph
      
      file=[file(1:char_to_verify-1) htmlenv sprintf('\n\n') file(label_clos_brac+1:length(file))];
      
      %let us skip the characters we added;
      char_to_verify=char_to_verify+length(htmlenv)-1;
      
      %ref_name
      if length(str_counter)==0
        ref_name{alt_counter}=['unnumbered' envidentifier];
      else
        ref_name{alt_counter}=[int2str(sec_num) '.' int2str(counter)];
      endif
      
    endif
    %
    
    
    
    
    %let us check if we are at a '\end{envtype}'
    exp_to_verify='\end{';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      file=[file(1:char_to_verify-1) '</div>' file(findclosingbrac(file,char_to_verify+length('\end{')-1)+1:length(file))];
    endif
    %
    
    
    
    
    char_to_verify = char_to_verify+1;
    
    if char_to_verify/length(file)>announce/100
      announce=announce+1;
      %disp(['Analysing character ' int2str(char_to_verify) ' of approximately ' int2str(length(file))]);
      waitbar(char_to_verify/length(file));
    endif
  endwhile
  close(convertbar)
  disp(sprintf('\n'))
  
  
  
  
  disp(['Cleaning up ' sprintf('''') '\texorpdfstring' sprintf('''') '...' sprintf('\n')]);
  char_to_verify=1;
  exp_to_verify='\texorpdfstring{';
  pos=strfind(file,exp_to_verify);
  
  while length(pos)>0
    tex_open_brac=pos(1)+length(exp_to_verify)-1;
    tex_clos_brac=findclosingbrac(file,tex_open_brac);
    pdf_open_brac=tex_clos_brac+1;
    pdf_clos_brac=findclosingbrac(file,pdf_open_brac);
    tex=file(tex_open_brac+1:tex_clos_brac-1);
    %keep only 'tex' text
    file=[file(1:pos(1)-1) tex file(pdf_clos_brac+1:length(file))];
    
    pos=strfind(file,exp_to_verify);
  endwhile
  
  %also clean up sidebar
  pos=strfind(sidebar,exp_to_verify);
  while length(pos)>0
    tex_open_brac=pos(1)+length(exp_to_verify)-1;
    tex_clos_brac=findclosingbrac(sidebar,tex_open_brac);
    pdf_open_brac=tex_clos_brac+1;
    pdf_clos_brac=findclosingbrac(sidebar,pdf_open_brac);
    tex=sidebar(tex_open_brac+1:tex_clos_brac-1);
    %keep only 'tex' text
    sidebar=[sidebar(1:pos(1)-1) tex sidebar(pdf_clos_brac+1:length(sidebar))];
    
    pos=strfind(sidebar,exp_to_verify);
  endwhile
  %
  
  
  
  
  %clear up '\tensor'
  disp(['Cleaning up ' sprintf('''') '\tensor' sprintf('''') '...' sprintf('\n')]);
  exp_to_verify='\tensor';
  pos=strfind(file,'\tensor'); %position of '\tensor'
  while length(pos)>0
    if strcmp(file(pos(1)+length('\tensor')),'[')
      bef_open=pos(1)+length('\tensor');
      bef_clos=findclosingbrac(file,bef_open);
      bef=[file(bef_open+1:bef_clos-1) '\!\!'];
    else
      bef_open=pos(1)+length('\tensor')-1;
      bef_clos=pos(1)+length('\tensor')-1;
      bef='';
    endif
    
    tensor_open=bef_clos+1;
    tensor_clos=findclosingbrac(file,tensor_open);
    tensor=file(tensor_open+1:tensor_clos-1);
    
    aft_open=tensor_clos+1;
    aft_clos=findclosingbrac(file,aft_open);
    
    aft=file(aft_open+1:aft_clos-1);
    
    file=[file(1:pos(1)-1) '\left.\right.' bef tensor aft file(aft_clos+1:length(file))];
    
    pos=strfind(file,'\tensor');
  endwhile
  
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %make tikzpictures. Requires ImageMagick; https://imagemagick.org/
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  k=strfind(file,'\begin{tikzpicture}');
  p=strfind(file,'\end{tikzpicture}');
  numberoftikz=length(k);
  tikzbar=waitbar(0,'Creating tikzpictures...');
  
  while length(k)>0
    
    waitbar((numberoftikz-length(k))/numberoftikz);
    
    disp([int2str(length(k)) ' tikz to go.'])
    
    tikz=file(k(length(k)):p(length(k))+length('\end{tikzpicture}')-1);
    latexcommands=fileread('src/latex_commands');
    latexcommands=latexcommands(strfind(latexcommands,'\begin{equation*}')(1)+length('\begin{equation*}'):strfind(latexcommands,'\end{equation*}')(1)-1);
    
    tikz=strrep(tikz,'\greaterthan ','>');
    tikz=strrep(tikz,'\smallerthan ','<');
    %now we will find the enclosing equation* environments
    
    open_eq=k(length(k))-length('\begin{equation*}');
    while 1-strcmp(file(open_eq:open_eq+length('\begin{equation*}')-1),'\begin{equation*}')
      open_eq=open_eq-1;
    endwhile
    
    clos_eq=p(length(k))+length('\end{tikzpicture}');
    while 1-strcmp(file(clos_eq:clos_eq+length('\end{equation*}')-1),'\end{equation*}')
      clos_eq=clos_eq+1;
    endwhile
    
    %build tikz as dvi and convert to png
    
    temp_tikz_filename=[original_filename '_tikz_' int2str(length(k))];
    temp_tikz_file = fopen([ temp_tikz_filename '.tex'],'w');
    temp_tikz_str = [ ...
      '\documentclass{standalone}' sprintf('\n') ...
      '\usepackage{amsmath}' sprintf('\n') ...
      '\usepackage{amssymb}' sprintf('\n') ...
      '\usepackage{tikz}' sprintf('\n') ...
      '\usepackage{mathrsfs}' sprintf('\n') ...
      '\usepackage{ifthen}' sprintf('\n') ...
      latexcommands sprintf('\n') ...
      '\begin{document}' sprintf('\n') ...
      tikz ...
      '\end{document}' ...
      ];
      
    temp_tikz_str=strrep(temp_tikz_str,'\','\\'); %technical details
    temp_tikz_str=strrep(temp_tikz_str,'%','%%'); %technical details
    
    fprintf(temp_tikz_file,temp_tikz_str);
    fclose(temp_tikz_file);
    
    system(['latex ' temp_tikz_filename ' > NUL']);
    system([ ...
    'convert -density 300 ' temp_tikz_filename '.dvi -flatten -quality 90 PNG24:' temp_tikz_filename '.png > NUL']);
    temp_tikz_im=imread([temp_tikz_filename '.png']);
    
    file=[file(1:open_eq-1) ...
    '<img src=' sprintf('''') temp_tikz_filename '.png' sprintf('''') ' class=' sprintf('''') 'tikzpicture' sprintf('''') ...
    ' style=' sprintf('''') 'width:' int2str(size(temp_tikz_im,2)/2) 'px' sprintf('''') '>' ...
    file(clos_eq+length('\end{equation*}'):length(file))];
    
    p(length(p))=[];
    k(length(k))=[];
    
    system(['del ' sprintf('"') temp_tikz_filename '.tex' sprintf('"') ' > NUL']);
  endwhile
  
  close(tikzbar);
  %delete temporary tex files
  system('del *.aux');
  system('del *.log');
  system('del *.dvi');
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Create references
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  disp('Creating references.')
  k=strfind(file,'\ref{');
  number_of_references=length(k);
  refbar=waitbar(0,'Creating references...');
  announce=1;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %CUSTOM REFERENCE NAMES
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  custom_refs
  
  while length(k)>0
    open_brac=k(length(k))+length('\ref{')-1;
    
    clos_brac=findclosingbrac(file,open_brac);
    
    label=file(open_brac+1:clos_brac-1);
    
    ref_id=new_label(find(strcmp(old_label,label)));
    
    file=[file(1:k(length(k))-1) ...
            '<a class=' sprintf('''') 'reference' sprintf('''') ' href=' sprintf('''') sec_file{ref_id} '.html#' int2str(ref_id) sprintf('''') '>' ...
            ref_name{ref_id} '</a>' ...
            file(clos_brac+1:length(file))];
    
    k(length(k))=[];
    
    if (number_of_references-length(k))/number_of_references>announce/100
      waitbar((number_of_references-length(k))/number_of_references);
      announce=announce+1;
    endif
    
  endwhile
  
  close(refbar);
  
  disp('Creating equation references.')
  k=strfind(file,'\eqref{');
  number_of_references=length(k);
  refbar=waitbar(0,'Creating equation references...');
  announce=1;
  while length(k)>0
    open_brac=k(length(k))+length('\eqref{')-1;
    
    clos_brac=findclosingbrac(file,open_brac);
    
    label=file(open_brac+1:clos_brac-1);
    
    ref_id=new_label(find(strcmp(old_label,label)));
    
    file=[file(1:k(length(k))-1) ...
            '<a class=' sprintf('''') 'reference' sprintf('''') ' href=' sprintf('''') sec_file{ref_id} '.html#' int2str(ref_id) sprintf('''') '>' ...
            '(' ref_name{ref_id} ')' '</a>' ...
            file(clos_brac+1:length(file))];
    
    k(length(k))=[];
    
    if (number_of_references-length(k))/number_of_references>announce/100
      waitbar((number_of_references-length(k))/number_of_references);
      announce=announce+1;
    endif
    
  endwhile
  
  close(refbar);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Create citations
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  disp('Creating citations.')
  k=strfind(file,'\cite');
  number_of_references=length(k);
  refbar=waitbar(0,'Creating citations...');
  announce=1;
  while length(k)>0
    char_to_verify=k(length(k));
    k(length(k))=[];
    
    if strcmp(file(char_to_verify+length('\cite')),'[')
      oparg_open_brac=char_to_verify+length('\cite');
      oparg_clos_brac=findclosingbrac(file,oparg_open_brac);
      oparg=[', ' file(oparg_open_brac+1:oparg_clos_brac-1)];
    else
      oparg_clos_brac=char_to_verify+length('\cite')-1;
      oparg='';
    endif
    
    open_brac=oparg_clos_brac+1;
    clos_brac=findclosingbrac(file,open_brac);
    
    citt=[',' file(open_brac+1:clos_brac-1) ','];
    commas=strfind(citt,',');
    citation_keys={};
    %let's make a cell array with all citation keys which appear
    for i=1:length(commas)-1
      citation_keys{i}=citt(commas(i)+1:commas(i+1)-1);
    endfor
    
    str_citation='[';
    for i=1:length(citation_keys);
      if i==1;
        str_citation=[str_citation '<a class=' sprintf('''') 'reference' sprintf('''') ' href=' sprintf('''') '../../HTML citations/' citation_keys{i} '.html' sprintf('''') ' target=' sprintf('''') '_blank' sprintf('''') '>' citation_keys{i} '</a>'];
      else
        str_citation=[str_citation ', <a class=' sprintf('''') 'reference' sprintf('''') ' href=' sprintf('''') '../../HTML citations/' citation_keys{i} '.html' sprintf('''') ' target=' sprintf('''') '_blank' sprintf('''') '>' citation_keys{i} '</a>'];
      endif
      str_citation=[str_citation ']'];
    endfor
    
    
    file=[file(1:char_to_verify-1) ...
            str_citation ...
            file(clos_brac+1:length(file))];
    
    if (number_of_references-length(k))/number_of_references>announce/100
      waitbar((number_of_references-length(k))/number_of_references);
      announce=announce+1;
    endif
    
  endwhile
  
  close(refbar);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %The following html code is standard for every page to be created
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  htmlload = [fileread('../../src/articles_html_head') ...
            sprintf('\n\n') '<title>' title '</title>' sprintf('\n\n') ...
            '</head>' sprintf('\n') '<body>' sprintf('\n\n') ...
            fileread('src/latex_commands') sprintf('\n\n') ...
            '<div id=' sprintf('''') 'sidebar' sprintf('''') 'class=' sprintf('''') 'sidebar' sprintf('''') '>' ...
            sidebar sprintf('\n') ...
            '</div>' sprintf('\n\n') ...
            fileread('../../src/articles_html_main')];
            
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Create title page with abstract
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  disp('Building front page.')
  
  curr_file = [  ...
    '<h1 class=' sprintf('''') 'maintitle' sprintf('''') '>' ...
    title ...
    '</h1>' sprintf('\n\n') ...
    authors ...
    ];
  
  published_text=fileread('src/published');
  if length(published_text)>0
    curr_file = [ curr_file sprintf('\n\n') ...
    '<div class=' sprintf('''') 'published' sprintf('''') '>' ...
    published_text ...
    '</div>'];
  endif
  
  %Let's find the abstract
  k=strfind(file,'\beginabstract');
  p=strfind(file,'\endabstract');
  if length(k)>0
    abstract_text=file(k+length('\beginabstract'):p-1);
    
    file=[file(1:k-1) file(p+length('\endabstract'):length(file))];
  else
    abstract_text='';
  endif
  
  if length(abstract_text)>0
    curr_file = [ curr_file ...
      sprintf('\n\n') ...
      '<div class=' sprintf('''') 'abstract' sprintf('''') '>' sprintf('\n') ...
      '<b>Abstract.</b> ' ...
      abstract_text sprintf('\n\n') ...
      '</div>'];
  endif
  curr_file = [htmlload sprintf('\n\n') curr_file sprintf('\n\n') '</body>' sprintf('\n') '</html>'];
  
  curr_file = strrep(curr_file,'\','\\');
  
  curr_page = fopen([original_filename '_front.html'],'w');
  
  fprintf(curr_page,curr_file);
  fclose(curr_page);
  
  %Now we separate the different sections and build the html file
  
  sec_starts=strfind(file,['<h2 class=' sprintf('''') 'section']);
  sec_starts(length(sec_starts)+1)=length(file)+1;
  
  for i=1:(length(sec_starts)-1)
    curr_page=[htmlload sprintf('\n\n') file(sec_starts(i):sec_starts(i+1)-1) '</body>' sprintf('\n') '</html>'];
    curr_page=strrep(curr_page,'\','\\'); %technical details
    curr_file=fopen([sec_filenames{i} '.html'],'w');
    fprintf(curr_file,curr_page);
    fclose(curr_file);
  endfor
  
  disp('Done.')
  
endfunction