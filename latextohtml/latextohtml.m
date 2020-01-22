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
%The text can be separated into numbered or unnembered sections and subsections. Unnembered (starred) subsubsections are supported. Chapters and parts are not supported.
%
%Sections will be broken up into different HTML files. A sidebar will have links to sections and to subsections.
%
%Avoid comments in-text.
%
%--- Counters and numbering ---
%
%Sections and subsections support counter. subsubsections do not.
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
    
    original_filename = latex_file_input;
  else
    original_filename = [latex_file_input '.tex'];
  endif
  
  file = fileread(original_filename);
  
  counter = 0;
  sec_num = 0;
  subsec_num = 0;
  
  %there are some unnembered elements which will need ids and/or classes, such as lists with custom label types and unnembered sections. Just to ensure they have unique classes or ids, let's use an alternative counter
  
  alt_counter=0;
  
  %we go char by char
  
  char_to_verify = 1;
  exp_to_verify = '';
  
  %find the title
  title='';
  exp_to_verify = '\title{';
  disp('Finding title')
  
  while char_to_verify < length(file)
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      open_brac = char_to_verify + length(exp_to_verify)-1;
      clos_brac = findclosingbrac(file,open_brac);
      
      title = file(open_brac+1:clos_brac-1);
      title=strrep(title,'\\','<br>');
      char_to_verify=length(file);
    endif
    char_to_verify=char_to_verify+1;
  endwhile
  
  disp(['The title is ' sprintf('''') title sprintf('''') '.'])
  
  sidebar = ['<h1 class=' sprintf('''') 'sidebar-title' sprintf('''') '>' ...
            title ...
            '</h1>'];
  char_to_verify = 1;
  
  %erase everything before '\begin{document}', and erase '\end{document}'
  file = file(strfind(file,'\begin{document}')+length('\begin{document}'): strfind(file,'\end{document}')-1);
 
 %Let's find the abstract
  while char_to_verify<length(file) && (1-strcmp(file(char_to_verify:char_to_verify+length('\begin{abstract}')-1),'\begin{abstract}'))
    char_to_verify=char_to_verify+1;
  endwhile
  
  if char_to_verify<length(file)
    abs_close=char_to_verify;
    while 1-strcmp(file(abs_close:abs_close+length('\end{abstract}')-1),'\end{abstract}')
      abs_close=abs_close+1;
    endwhile
    
    abstract_text=file(char_to_verify+length('\begin{abstract}'):abs_close-1);
    
    file=file(abs_close+length('\end{abstract}'):length(file));
  endif

  file=[sprintf('\n\n') file];
  
  %first we input all files
  exp_to_verify = '\input{';
  input_pos=strfind(file,exp_to_verify);
  
  while length(input_pos)>0
    disp(['There are ' int2str(length(file)) ' characters and ' int2str(length(input_pos)) ' files to be input.'])
    
    open_brac = input_pos(1)+ length(exp_to_verify)-1;
    clos_brac = findclosingbrac(file,open_brac);
    file_to_input_name = ['   ' file(open_brac+1:clos_brac-1)];
    
    if strcmp(file_to_input_name(length(file_to_input_name)-3:length(file_to_input_name)),'.tex')
      file_to_input = fileread(file(open_brac+1:clos_brac-1));
    else
      file_to_input = fileread([file(open_brac+1:clos_brac-1) '.tex']);
    endif
    
    file = [file(1:input_pos(1)-1) ...
              file_to_input ...
              file(clos_brac+1:length(file))];
      
    input_pos=strfind(file,exp_to_verify);
  endwhile
  
  disp(['There are ' int2str(length(file)) ' characters.'])
  
  %now we remove comments
  disp('Removing comments.')
  
  comments=strfind(file,'%');
  
  while length(comments)>0
    j=comments(length(comments))+1;
    while 1-strcmp(file(j),sprintf('\n'))
      j=j+1;
    endwhile
    file=[file(1:comments(length(comments))-1) file(j+1:length(file))];
    comments(length(comments))=[];
  endwhile
  
  
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
  while char_to_verify < length(file)
    
    %-----------------------------------------------------------------
    %First we check the in-text commands inside braces
    %-----------------------------------------------------------------
    
    %let us check if we are at a '\input{'
    exp_to_verify = '\input{';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      open_brac = char_to_verify + length(exp_to_verify)-1;
      clos_brac = findclosingbrac(file,open_brac);
      file_to_input_name = ['   ' file(open_brac+1:clos_brac-1)];
      
      if strcmp(file_to_input_name(length(file_to_input_name)-3:length(file_to_input_name)),'.tex')
        file_to_input = fileread(file(open_brac+1:clos_brac-1));
      else
        file_to_input = fileread([file(open_brac+1:clos_brac-1) '.tex']);
      endif
      
      file = [file(1:char_to_verify-1) ...
                file_to_input ...
                file(clos_brac+1:length(file))];
      
      char_to_verify = char_to_verify -1;
    endif
    %
    
    
    
    
    %check for paragraph
    exp_to_verify = sprintf('\n\n');
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      %delete all white spaces after these two new lines
      while (length(file)>char_to_verify+1) && (isstrprop(file(char_to_verify+length(exp_to_verify)),'wspace'))
        if length(file)==char_to_verify+2
          file=file(1:char_to_verify+1);
        else
          file=[file(1:char_to_verify+1) file(char_to_verify+3:length(file))];
        endif
      endwhile
      
      if inparagraph
        file=[file(1:char_to_verify) '</p>' sprintf('\n') file(char_to_verify+1:length(file))];
        inparagraph=0;
        char_to_verify=char_to_verify+length('</p>');
      elseif (1-inparagraph) && length(file)>char_to_verify+1 && ...
        (isstrprop(file(char_to_verify+2),'alphanum') || ...
          strcmp(file(char_to_verify+2),'$') || ...
          strcmp(file(char_to_verify+2:char_to_verify+2+length('\text')-1),'\text') || ...
          strcmp(file(char_to_verify+2:char_to_verify+2+length('\emph')-1),'\emph') || ...
          strcmp(file(char_to_verify+2:char_to_verify+2+length('\underline')-1),'\underline') || ...
          strcmp(file(char_to_verify+2:char_to_verify+2+length('\uline')-1),'\uline') || ...
          strcmp(file(char_to_verify+2:char_to_verify+2+length('\input')-1),'\input') ...
          )
        file=[ file(1:char_to_verify) '<p>' sprintf('\n') file(char_to_verify+2:length(file))];
        inparagraph=1;
        char_to_verify=char_to_verify+1;        
      endif
      
    endif
    %
    
    
    
    
    %check if we are at a '\maketitle'
    exp_to_verify = '\maketitle';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      file=[file(1:char_to_verify-1) file(char_to_verify+length('\maketitle'):length(file))];
    endif
    %
    
    
    
    
    %let us check if we are at a '$$'
    exp_to_verify = '$$';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      char_to_verify=char_to_verify+2;
      
      while 1-strcmp(file(char_to_verify:char_to_verify+1),'$$')
        char_to_verify=char_to_verify+1;
      endwhile
      
      char_to_verify=char_to_verify+2;
    endif
    %
    
    
    
    
    %let us check if we are at a '$'
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
      file(char_to_verify)=[];
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
    
    
    
    
    %let us check if we are at a '\underline{'
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
    
    
    
    
    %let us check if we are at a '\section'
    exp_to_verify = '\section';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      if strcmp(file(char_to_verify+length(exp_to_verify)),'*');
        alt_counter=alt_counter+1;
        str_sec_num='';
        label=[' id=' sprintf('''') 'sec' int2str(alt_counter) sprintf('''')];
      else
        sec_num = sec_num+1;
        str_sec_num = [int2str(sec_num) '. '];
        %reset subsection and counter
        subsec_num = 0;
        counter=0;
        label=[' id=' sprintf('''') 'sec' int2str(sec_num) sprintf('''')];
      endif
      
      open_brac = char_to_verify+length(exp_to_verify);
      while 1-strcmp(file(open_brac),'{')
        open_brac=open_brac+1;
      endwhile
      
      clos_brac = findclosingbrac(file,open_brac);
      
      section_title=file(open_brac+1:clos_brac-1);
      
      label_clos_brac=clos_brac;
      
      %let us look for a section label
      if strcmp(file(clos_brac+1:clos_brac+length('\label{')),'\label{')
        
        label_open_brac = clos_brac+length('\label{');
        label_clos_brac = findclosingbrac(file,label_open_brac);
        label=[' id=' sprintf('''') ...
                file(label_open_brac+1:label_clos_brac-1) ...
                sprintf('''')];
      endif
      
      %update sidebar
      sidebar=[sidebar sprintf('\n') ...
              '<hr>' sprintf('\n')' ...
              '<h1 class=' sprintf('''') 'sidebar-section' sprintf('''') '>' ...
              '<a href=' sprintf('''') '#' label(1+length([' id=' sprintf('''')]):length(label)-1) sprintf('''') '>' ...
              str_sec_num section_title ...
              '</a></h1>'];
              
      file = [file(1:char_to_verify-1) ...
              '<h2 class=' sprintf('''') 'section' sprintf('''') label '>' ...
              str_sec_num section_title ...
              '</h2>' ...
              file(label_clos_brac+1:length(file))];
        
      char_to_verify = char_to_verify + length(['<h2 class=' sprintf('''') 'section' sprintf('''') label '>' str_sec_num]) - 1;
    endif
    %
    
    
    
    
    %let us check if we are at a '\subsection'
    exp_to_verify = '\subsection';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      if strcmp(file(char_to_verify+length(exp_to_verify)),'*');
        alt_counter=alt_counter+1;
        str_subsec_num='';
        label=[' id=' sprintf('''') 'subsec' int2str(alt_counter) sprintf('''')];
      else
        subsec_num = subsec_num+1;
        str_subsec_num = [int2str(sec_num) '.' int2str(subsec_num) '. '];
      endif
      
      open_brac = char_to_verify+length(exp_to_verify);
      while 1-strcmp(file(open_brac),'{')
        open_brac=open_brac+1;
      endwhile
      
      clos_brac = findclosingbrac(file,open_brac);
      
      subsection_title=file(open_brac+1:clos_brac-1);
      
      label=[' id=' sprintf('''') 'subsec' int2str(sec_num) '.' int2str(subsec_num) sprintf('''')];
      label_clos_brac=clos_brac;
      
      %let us look for a section label
      if strcmp(file(clos_brac+1:clos_brac+length('\label{')),'\label{')
        
        label_open_brac = clos_brac+length('\label{');
        label_clos_brac = findclosingbrac(file,label_open_brac);
        label = [' id=' sprintf('''') ...
                file(label_open_brac+1:label_clos_brac-1)...
                sprintf('''')];
      endif
      
      %update sidebar
      sidebar=[sidebar sprintf('\n') ...
              '<h2 class=' sprintf('''') 'sidebar-subsection' sprintf('''') '>' ...
              '<a href=' sprintf('''') '#' label(strfind(label,sprintf(''''))(1)+1:strfind(label,sprintf(''''))(2)-1) sprintf('''') '>' ...
              str_subsec_num subsection_title ...
              '</a></h2>'];
              
      file = [file(1:char_to_verify-1) ...
              '<h3 class=' sprintf('''') 'subsection' sprintf('''') label '>' ...
              str_subsec_num subsection_title ...
              '</h3>' ...
              file(label_clos_brac+1:length(file))];
        
      char_to_verify = char_to_verify + length(['<h3 class=' sprintf('''') 'subsection' sprintf('''') label '>' str_subsec_num]) - 1;
    endif
    %
    
    
    
    
    %let us check if we are at a '\subsubsection*{'
    exp_to_verify = '\subsubsection*{';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      open_brac = char_to_verify+length(exp_to_verify)-1;
      clos_brac = findclosingbrac(file,open_brac);
      
      subsubsection_title=file(open_brac+1:clos_brac-1);
      
      alt_counter=alt_counter+1;
      
      label=[' id=' sprintf('''') 'subsubsec' int2str(alt_counter) sprintf('''')];

      file = [file(1:char_to_verify-1) ...
              '<h4 class=' sprintf('''') 'subsubsection' sprintf('''') label '>' ...
              subsubsection_title ...
              '</h4>' ...
              file(clos_brac+1:length(file))];
        
      char_to_verify = char_to_verify + length(['<h4 class=' sprintf('''') 'subsubsection' sprintf('''') label '>']) - 1;
    endif
    %
    
    
    
    
    %let us check if we are at a '\[...\]'. 
    exp_to_verify = '\[';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      %We need to find the closing part of the equation
      close_eq=char_to_verify+length('\[');
      while 1-strcmp(file(close_eq:close_eq+1),'\]')
        close_eq=close_eq+1;
      endwhile
      
      %check if there is an ntag.
      j=char_to_verify+length('\[');
      while j<close_eq-length('\ntag')+1
        
        if strcmp(file(j:j+length('\ntag')-1),'\ntag')
          counter=counter+1;
          ntag_start=j;
          %rewrite this ntag as tag
          file = [file(1:ntag_start-1) ...
                  '\tag{' int2str(sec_num) '.' int2str(counter) '}' ...
                  file(ntag_start+length('\ntag'):length(file))];
          
          %since we rewrote the math environment, we need to update close_eq. The new one will be larger, so we can just continue from the current position
          while 1-strcmp(file(close_eq:close_eq+1),'\]')
            close_eq=close_eq+1;
          endwhile
          j=close_eq;
        endif
        j=j+1;
      endwhile
      
      label='';
      
      %look for an equation label
      j=char_to_verify+length('\[');
      while j<close_eq-length('\label{')+2
        
        if strcmp(file(j:j+length('\label{')-1),'\label{')
          label_open_brac = j+length('\label{')-1;
          label_clos_brac = findclosingbrac(file,label_open_brac);
          label=[' id=' sprintf('''') file(label_open_brac+1:label_clos_brac-1)...
          sprintf('''')];
          
          %remove the label
          file=[file(1:j-1) file(label_clos_brac+1:length(file))];
          
          %update close_eq
          close_eq=char_to_verify+2;
          while 1-strcmp(file(close_eq:close_eq+1),'\]')
            close_eq=close_eq+1;
          endwhile
          j=close_eq;
        endif
        j=j+1;
      endwhile
      
      %We need to remove possible empty lines after \[ and before \]. For this, we simply erase all newlines and space (whitespaces) in those positions.
      
      while isstrprop(file(char_to_verify+length('\[')),'wspace')
        file=[file(1:char_to_verify+1) file(char_to_verify+3:length(file))];
        close_eq=close_eq-1;
      endwhile
      
      while isstrprop(file(close_eq-1),'wspace')
        file=[file(1:close_eq-2) file(close_eq:length(file))];
        close_eq=close_eq-1;
      endwhile
      
      math=file(char_to_verify+2:close_eq-1);
      math=strrep(math,'<','\smallerthan ');
      math=strrep(math,'>','\greaterthan ');
      
      file = [file(1:char_to_verify-1) ...
        '<div class=' sprintf('''') 'equation' sprintf('''') label '>' sprintf('\n')...
        '\begin{equation*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{equation*}' sprintf('\n') ...
        '</div>' ...
        file(close_eq+2:length(file))];
      
      %skip the whole math to keep it unchanged; the easist way is simply to see where the div above is closed. Even if 'file' was changes, we just care about lengths, so it doesn't matter.
      char_to_verify = length([file(1:char_to_verify-1) ...
        '<div class=' sprintf('''') 'equation' sprintf('''') label '>' sprintf('\n')...
        '\begin{equation*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{equation*}' sprintf('\n') ...
        '</div>']);
    endif
    %
    
    
    
    
    %check if we are at a '\begin{equation*}...\end{equation*}'. 
    exp_to_verify = '\begin{equation*}';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      %find the closing part of the equation
      close_eq=char_to_verify+length('\begin{equation*}');
      while 1-strcmp(file(close_eq:close_eq+length('\end{equation*}')-1),'\end{equation*}')
        close_eq=close_eq+1;
      endwhile
      
      %check if there is an ntag.
      j=char_to_verify+length('\begin{equation*}');
      while j<close_eq-length('\ntag')+1
        
        if strcmp(file(j:j+length('\ntag')-1),'\ntag')
          counter=counter+1;
          ntag_start=j;
          %rewrite this ntag as tag
          file = [file(1:ntag_start-1) ...
                  '\tag{' int2str(sec_num) '.' int2str(counter) '}' ...
                  file(ntag_start+length('\ntag'):length(file))];
          
          %since we rewrote the math environment, we need to update close_eq. The new one will be larger, so we can just continue from the current position
          while 1-strcmp(file(close_eq:close_eq+length('\end{equation*}')-1,'\end{equation*}'))
            close_eq=close_eq+1;
          endwhile
          j=close_eq;
        endif
        j=j+1;
      endwhile
      
      
      label='';
      
      %look for an equation label
      j=char_to_verify+length('\begin{equation*}');
      while j<close_eq-length('\label{')+2
        
        if strcmp(file(j:j+length('\label{')-1),'\label{')
          label_open_brac = j+length('\label{')-1;
          label_clos_brac = findclosingbrac(file,label_open_brac);
          label=[' id=' sprintf('''') file(label_open_brac+1:label_clos_brac-1)...
          sprintf('''')];
          
          %remove the label
          file=[file(1:j-1) file(label_clos_brac+1:length(file))];
          
          %update close_eq
          close_eq=char_to_verify+2;
          while 1-strcmp(file(close_eq:close_eq+1),'\end{equation*}')
            close_eq=close_eq+1;
          endwhile
          j=close_eq;
        endif
        j=j+1;
      endwhile
      
      %We need to remove possible empty lines after \begin{equation*} and before \end{equation*}. For this, we simply erase all newlines in those positions.
      
      while isstrprop(file(char_to_verify+length('\begin{equation*}')),'wspace')
        file=[file(1:char_to_verify+length('\begin{equation*}')-1) file(char_to_verify+length('\begin{equation*}')+1:length(file))];
        close_eq=close_eq-1;
      endwhile
      
      while isstrprop(file(close_eq-1),'wspace')
        file=[file(1:close_eq-2) file(close_eq:length(file))];
        close_eq=close_eq-1;
      endwhile
      
      math=file(char_to_verify+length('\begin{equation*}'):close_eq-1);
      math=strrep(math,'<','\smallerthan ');
      math=strrep(math,'>','\greaterthan ');
      
      file = [file(1:char_to_verify-1) ...
        '<div class=' sprintf('''') 'equation' sprintf('''') label '>' sprintf('\n')...
        '\begin{equation*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{equation*}' sprintf('\n') ...
        '</div>' ...
        file(close_eq+length('\end{equation*}'):length(file))];
        
      char_to_verify = length([file(1:char_to_verify-1) ...
        '<div class=' sprintf('''') 'equation' sprintf('''') label '>' sprintf('\n')...
        '\begin{equation*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{equation*}' sprintf('\n') ...
        '</div>'])
    endif
    %
    
    
    
    
    %check if we are at a '\begin{align*}...\end{align*}'. 
    exp_to_verify = '\begin{align*}';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      %find the closing part of the equation
      close_eq=char_to_verify+length('\begin{align*}');
      while 1-strcmp(file(close_eq:close_eq+length('\end{align*}')-1),'\end{align*}')
        close_eq=close_eq+1;
      endwhile
      
      %check if there is an ntag.
      j=char_to_verify+length('\begin{align*}');
      while j<close_eq-length('\ntag')+1
        
        if strcmp(file(j:j+length('\ntag')-1),'\ntag')
          counter=counter+1;
          ntag_start=j;
          %rewrite this ntag as tag
          file = [file(1:ntag_start-1) ...
                  '\tag{' int2str(sec_num) '.' int2str(counter) '}' ...
                  file(ntag_start+length('\ntag'):length(file))];
          
          %since we rewrote the math environment, we need to update close_eq. The new one will be larger, so we can just continue from the current position
          while 1-strcmp(file(close_eq:close_eq+length('\end{align*}')-1,'\end{align*}'))
            close_eq=close_eq+1;
          endwhile
          j=close_eq;
        endif
        j=j+1;
      endwhile
      
      
      label='';
      
      %look for an equation label
      j=char_to_verify+length('\begin{align*}');
      while j<close_eq-length('\label{')+2
        
        if strcmp(file(j:j+length('\label{')-1),'\label{')
          label_open_brac = j+length('\label{')-1;
          label_clos_brac = findclosingbrac(file,label_open_brac);
          label=[' id=' sprintf('''') file(label_open_brac+1:label_clos_brac-1)...
          sprintf('''')];
          
          %remove the label
          file=[file(1:j-1) file(label_clos_brac+1:length(file))];
          
          %update close_eq
          close_eq=char_to_verify+2;
          while 1-strcmp(file(close_eq:close_eq+1),'\end{align*}')
            close_eq=close_eq+1;
          endwhile
          j=close_eq;
        endif
        j=j+1;
      endwhile
      
      %We need to remove possible empty lines after \begin{align*} and before \end{align*}. For this, we simply erase all newlines in those positions.
      
      while isstrprop(file(char_to_verify+length('\begin{align*}')),'wspace')
        file=[file(1:char_to_verify+length('\begin{align*}')-1) file(char_to_verify+length('\begin{align*}')+1:length(file))];
        close_eq=close_eq-1;
      endwhile
      
      while isstrprop(file(close_eq-1),'wspace')
        file=[file(1:close_eq-2) file(close_eq:length(file))];
        close_eq=close_eq-1;
      endwhile
      
      math=file(char_to_verify+length('\begin{align*}'):close_eq-1);
      math=strrep(math,'<','\smallerthan ');
      math=strrep(math,'>','\greaterthan ');
      
      file = [file(1:char_to_verify-1) ...
        '<div class=' sprintf('''') 'equation' sprintf('''') label '>' sprintf('\n')...
        '\begin{align*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{align*}' sprintf('\n') ...
        '</div>' ...
        file(close_eq+length('\end{align*}'):length(file))];
        
      char_to_verify = length([file(1:char_to_verify-1) ...
        '<div class=' sprintf('''') 'equation' sprintf('''') label '>' sprintf('\n')...
        '\begin{align*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{align*}' sprintf('\n') ...
        '</div>']);
    endif
    %
    
    
    
    
    %let us check if we are at a '\begin{enumerate}'
    exp_to_verify = '\begin{enumerate}';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      %let us check if there is any label. The labels should be of the form (\alph*), \roman*., etc.
      list_class='';
      list_css='';
      label_close=char_to_verify+length('\begin{enumerate}')-1;
      
      if strcmp(file(char_to_verify+length(exp_to_verify):char_to_verify+length(exp_to_verify)+length('[label=')-1),'[label=')
        
        alt_counter=alt_counter+1;
        list_class=[' class=' sprintf('''') 'alt altlist' int2str(alt_counter) sprintf('''')];
        
        label_open = char_to_verify+length(exp_to_verify);
        label_close = findclosingbrac(file,label_open);
        
        j=label_open+length('[label=');
        while j<label_close
          if strcmp(file(j:j+length('\alph*')-1),'\alph*')
            list_css=[list_css ' counter(listcounter,lower-alpha)' ];
            j=j+length('\alph*');
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
      %look for label
      label_clos_brac=char_to_verify+length(exp_to_verify)-1;
      
      %remember: we added two newlines after \item
      if strcmp(file(char_to_verify+length(exp_to_verify)+2:char_to_verify+length(exp_to_verify)+length('\label{')-1+2),'\label{')
        label_open_brac=char_to_verify+length(exp_to_verify)+length('\label{')-1+2;
        label_clos_brac=findclosingbrac(file,label_open_brac);
        
        label=[' id=' sprintf('''') ...
          file(label_open_brac+1:label_clos_brac-1) ...
          sprintf('''')];
      else
        label='';
      endif
      
      if in_list_item
        file=[file(1:char_to_verify-1) ...
          '</li>' sprintf('\n\n') ...
          '<li' label '>' sprintf('\n\n') ...
          file(label_clos_brac+1:length(file))];
          
        char_to_verify=char_to_verify+length(['</li>' sprintf('\n\n') '<li' label '>'])-1;
        
      else
        in_list_item=1;
        file=[file(1:char_to_verify-1) ...
          '<li' label '>' sprintf('\n\n') ...
          file(label_clos_brac+1:length(file))];
        
        char_to_verify=char_to_verify+length(['<li' label '>'])-1;
      endif
      
    endif
    %
    
    
    
    
    %check if we are at a '\end{enumerate}'
    exp_to_verify = '\end{enumerate}';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      in_list_item=0;
      
      file=[file(1:char_to_verify-1) '</li>' sprintf('\n') '</ol>' file(char_to_verify+length('\end{enumerate}'):length(file))];
      
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
        strcounter='';
      else
        numbered_env=1;
        counter=counter+1;
        strcounter=[' <span class=' sprintf('''') 'counter' sprintf('''') '>'  ...
        int2str(sec_num) '.' int2str(counter) '</span>'];
      endif
      
      %look for the label
      if length(file)>envtype_clos_brac+length('\label{')-1 && ...
        strcmp(file(envtype_clos_brac+1:envtype_clos_brac+length('\label{')),'\label{')
        
        label_open_brac=envtype_clos_brac+length('\label{');
        label_clos_brac=findclosingbrac(file,label_open_brac);
        label=[' id=' sprintf('''') ...
                file(label_open_brac+1:label_clos_brac-1) ...
                sprintf('''')];
      elseif numbered_env
        label_clos_brac=envtype_clos_brac;
        label = [' id=' sprintf('''') envtype int2str(counter) sprintf('''')];
      else
        label_clos_brac=envtype_clos_brac;
        label='';
      endif
      
      %Now the corresponding HTML code
      htmlenv= [...
        '<div class=' sprintf('''') envtype sprintf('''') label sprintf('>\n') ...
        '<span class=' sprintf('''') 'envidentifier' sprintf('''') '>' envidentifier '</span>' strcounter];
      
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
    endif
    %
    
    
    
    %let us check if we are at any other environment
    exp_to_verify = '\begin{';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify) 
      
      envtype_open_brac=char_to_verify+length('\begin{')-1;
      envtype_clos_brac=findclosingbrac(file,envtype_open_brac);
      
      %anything between those two is the environment type
      envtype=file(envtype_open_brac+1:envtype_clos_brac-1);
    
      %check if there is an optional argument.
      if strcmp(file(envtype_clos_brac+1),'[')
        oparg_open_brac=envtype_clos_brac+1;
        oparg_clos_brac=findclosingbrac(file,oparg_open_brac);
        
        %erase braces right inside te optional argument
        if strcmp(file(oparg_open_brac+1),'{') && strcmp(file(oparg_clos_brac-1),'}')
          file(oparg_clos_brac-1)=[];
          file(oparg_open_brac+1)=[];
          oparg_clos_brac=oparg_clos_brac-2;
        endif
        
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
        strcounter='';
      else
        numbered_env=1;
        counter=counter+1;
        strcounter=[' <span class=' sprintf('''') 'envcounter' sprintf('''') '>'  ...
        int2str(sec_num) '.' int2str(counter) '</span>'];
      endif
      
      %look for the label
      if length(file)>oparg_clos_brac+length('\label{')-1 && ...
        strcmp(file(oparg_clos_brac+1:oparg_clos_brac+length('\label{')),'\label{')
        
        label_open_brac=oparg_clos_brac+length('\label{');
        label_clos_brac=findclosingbrac(file,label_open_brac);
        label=[' id=' sprintf('''') ...
                file(label_open_brac+1:label_clos_brac-1) ...
                sprintf('''')];
      elseif numbered_env
        label_clos_brac=oparg_clos_brac;
        label = [' id=' sprintf('''') envtype int2str(counter) sprintf('''')];
      else
        label_clos_brac=oparg_clos_brac;
        label='';
      endif
      
      %Now the corresponding HTML code
      envidentifier=[upper(envtype(1)) envtype(2:length(envtype))];
      
      htmlenv= ['<div class=' sprintf('''') envtype sprintf('''') label sprintf('>\n') ...
      '<span class=' sprintf('''') 'envidentifier' sprintf('''') '>' envidentifier '</span>' strcounter oparg '.'];
      
      if numbered_env
        htmlenv=['<!-- ' int2str(sec_num) '.' int2str(counter) ' -->' ...
                sprintf('\n') htmlenv ];
      endif
      
      %let us simply keep the parts before the i-th position, the rewritten environment, and whatever's after the environment has ended. New lines for paragraph
      
      file=[file(1:char_to_verify-1) htmlenv sprintf('\n\n') file(label_clos_brac+1:length(file))];
      
      %let us skip the characters we added; notice that we add 1 at the end of the 'while'
      char_to_verify=char_to_verify+length(htmlenv)-1;
    endif
    %
    
    
    
    
    %let us check if we are at a '\end{envtype}'
    exp_to_verify='\end{';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      file=[file(1:char_to_verify-1) '</div>' file(findclosingbrac(file,char_to_verify+length('\end{')-1)+1:length(file))];
    endif
    %
    
    
    
    
    char_to_verify = char_to_verify+1;
    
    if 1000*announce < char_to_verify +1
      announce=announce+1;
      disp(['Analysing character ' int2str(char_to_verify) ' of approximately ' int2str(length(file))]);
    endif
  endwhile
  
  
  
  
  
  disp(['Cleaning up ' sprintf('''') 'texorpdfstring' sprintf('''') '...']);
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
  disp('Clearing up \tensor');
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
  
  
  
  
  
  %make tikzpictures. Requires ImageMagick; https://imagemagick.org/
  k=strfind(file,'\begin{tikzpicture}');
  p=strfind(file,'\end{tikzpicture}');
  
  while length(k)>0
    
    disp([int2str(length(k)) ' tikz to go.'])
    
    tikz=file(k(length(k)):p(length(k))+length('\end{tikzpicture}')-1);
    latexcommands=fileread('src\latex_commands');
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
    
    temp_tikz_filename=[original_filename(1:length(original_filename)-4) '_tikz_' int2str(length(k))];
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
  endwhile
  
  %delete temporary tex files
  system('del *.aux');
  system('del *.log');
  system('del *.dvi');
  
  
  
  
  %now we build the html the file
  disp('Building HTML')
  
  htmlload = [fileread('src/html_head') ...
              sprintf('\n\n') '<title>' title '</title>' sprintf('\n\n') ...
              '</head>' sprintf('\n') '<body>' sprintf('\n\n') ...
              fileread('src/latex_commands') sprintf('\n\n') ...
              '<div id=' sprintf('''') 'sidebar' sprintf('''') 'class=' sprintf('''') 'sidebar' sprintf('''') '>' ...
              sidebar sprintf('\n') ...
              '</div>' sprintf('\n\n') ...
              fileread('src/html_main')];
  
  file = [htmlload sprintf('\n\n') file sprintf('\n\n') '</body>' sprintf('\n') '</html>'];
  new_file=fopen([original_filename(1:length(original_filename)-4) '_converted.html'],'w'); %create empty html file
  file=strrep(file,'\','\\'); %technical details
  file=strrep(file,'%','%%'); %technical details
  fprintf(new_file,file);
  fclose(new_file);
  
  disp('Done.')
endfunction
