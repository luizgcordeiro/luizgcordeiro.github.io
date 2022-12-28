function latextomoodle(latex_file_input)
  
  original_filename = ['   ' latex_file_input];
  
  if strcmp(original_filename(length(original_filename)-3:length(original_filename)),'.tex')
    original_filename = latex_file_input(1:length(latex_file_input)-4);
  else
    original_filename = latex_file_input;
  endif
  
  file = fileread([original_filename '.tex']);
  
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
  file=strrep(file,'(y)','( y )');
  file=strrep(file,'(h)','( h )');
  %remove '\qedhere's
  file=strrep(file,'\qedhere','');
  
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
  
  counter=0;
  
  disp(['-----' sprintf('\n') 'Trimming complete.'])
  char_to_verify=1;
  announce=1;
  
  convertbar=waitbar(0,'Converting LaTeX to HTML...');
  disp(['-----' sprintf('\n') 'Converting LaTeX to HTML.'])
  
  file=[sprintf('\n\n') file];
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
      
      file=[file(1:char_to_verify-1) '\('  math '\)' file(closing_math+1:length(file))];
      char_to_verify=char_to_verify+length(math)+3;
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
    
    
    
    
    %check if we are at a '\hrule'
    exp_to_verify = '\hrule';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      file = [file(1:char_to_verify-1) ...
              '<hr/>' ...
              file(char_to_verify+length('\hrule'):length(file))];
      
      char_to_verify = char_to_verify + length('<hr/>')-1;
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
    
    
    
    
	%let us check if we are at a '\subsection'
    exp_to_verify = '\subsection*';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      open_brac=char_to_verify+length('\subsection*{')-1;
      
      clos_brac = findclosingbrac(file,open_brac);
      
      subsection_title=file(open_brac+1:clos_brac-1);
      
      label_clos_brac=clos_brac;
       
      file = [file(1:char_to_verify-1) ...
              '<h3 class=' sprintf('''') 'subsection' sprintf('''') '>' ...
              subsection_title ...
              '</h3>' ...
              file(label_clos_brac+1:length(file))];
        
      char_to_verify = char_to_verify + length(['<h3 class=' sprintf('''') 'subsection' sprintf('''') '>']) - 1;
      
    endif
    %
	
    %let us check if we are at a '\[...\]'. 
    exp_to_verify = '\[';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
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
                  '\tag{' int2str(counter) '}' ...
                  file(ntag_start+length('\ntag'):length(file))];
          
        %since we rewrote the math environment, we need to update close_eq.
		close_eq=char_to_verify;
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
      
      file = [file(1:char_to_verify-1) ...
        '<div>' sprintf('\n')...
        '\begin{equation*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{equation*}' sprintf('\n') ...
        '</div>' ...
        file(close_eq+length('\]'):length(file))];
      
      %skip the whole math to keep it unchanged; the easist way is simply to see where the div above is closed. Even if 'file' was changes, we just care about lengths, so it doesn't matter.
      char_to_verify = length([file(1:char_to_verify-1) ...
        '<div>' sprintf('\n')...
        '\begin{equation*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{equation*}' sprintf('\n') ...
        '</div>'])-1;
    endif
    %
    
    
    
    
    %check if we are at a '\begin{equation*}...\end{equation*}'. 
    exp_to_verify = '\begin{equation*}';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
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
                  '\tag{' int2str(counter) '}' ...
                  file(ntag_start+length('\ntag'):length(file))];
          
        %since we rewrote the math environment, we need to update close_eq.
		close_eq=char_to_verify;
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
      
      file = [file(1:char_to_verify-1) ...
        '<div>' sprintf('\n')...
        '\begin{equation*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{equation*}' sprintf('\n') ...
        '</div>' ...
        file(close_eq+length('\end{equation*}'):length(file))];
      
      %skip the whole math to keep it unchanged; the easist way is simply to see where the div above is closed. Even if 'file' was changes, we just care about lengths, so it doesn't matter.
      char_to_verify = length([file(1:char_to_verify-1) ...
        '<div>' sprintf('\n')...
        '\begin{equation*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{equation*}' sprintf('\n') ...
        '</div>']);
    endif
    %
    
    
    
    
    %check if we are at a '\begin{align*}...\end{align*}'. 
    exp_to_verify = '\begin{align*}';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
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
                  '\tag{' int2str(counter) '}' ...
                  file(ntag_start+length('\ntag'):length(file))];
          
        %since we rewrote the math environment, we need to update close_eq.
		close_eq=char_to_verify;
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
      
      file = [file(1:char_to_verify-1) ...
        '<div>' sprintf('\n')...
        '\begin{align*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{align*}' sprintf('\n') ...
        '</div>' ...
        file(close_eq+length('\end{align*}'):length(file))];
      
      %skip the whole math to keep it unchanged; the easist way is simply to see where the div above is closed. Even if 'file' was changes, we just care about lengths, so it doesn't matter.
      char_to_verify = length([file(1:char_to_verify-1) ...
        '<div>' sprintf('\n')...
        '\begin{align*}' sprintf('\n') ...
        math ...
        sprintf('\n') '\end{align*}' sprintf('\n') ...
        '</div>']);
    endif
    %
    
    
    
    
    %let us check if we are at a '\begin{enumerate}'
    exp_to_verify = '\begin{enumerate}';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
		file=[file(1:char_to_verify-1) '<ol>'  file(char_to_verify+length(exp_to_verify):length(file))];
      
		char_to_verify=char_to_verify+length(['<ol>'])-1;
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
      
      label_clos_brac=char_to_verify+length('\item')-1;
      
      if in_list_item
        file=[file(1:char_to_verify-1) ...
          '</li>' sprintf('\n\n') ...
          '<li>' sprintf('\n\n') ...
          file(label_clos_brac+1:length(file))];
          
        char_to_verify=char_to_verify+length(['</li>' sprintf('\n\n') '<li>'])-1;
        
      else
        in_list_item=1;
        file=[file(1:char_to_verify-1) ...
          '<li>' sprintf('\n\n') ...
          file(label_clos_brac+1:length(file))];
        
        char_to_verify=char_to_verify+length(['<li>'])-1;
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
	
    
    
    
    %let us check if we are at a '\begin{proof}'
    exp_to_verify = '\begin{proof}';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify) 
      
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
        envidentifier='Prova';
      endif
      
      
      %Now the corresponding HTML code
      
      htmlenv= ['<div style=' sprintf('''') 'margin-bottom: 5px; margin-top: 5px; padding: 5px 5px 0 5px; border: 1px solid gray; border-radius: 5px;' sprintf('''') sprintf('>\n') ...
      '<i>' envidentifier '</i>.'];
      
      %let us simply keep the parts before the i-th position, the rewritten environment, and whatever's after the environment has ended. New lines for paragraph
      
      file=[file(1:char_to_verify-1) htmlenv sprintf('\n\n') file(oparg_clos_brac+1:length(file))];
      
      %let us skip the characters we added;
      char_to_verify=char_to_verify+length(htmlenv)-1;
      
    endif
    %
    
	
	
	
	  
    %check '\begin{quote}'
    exp_to_verify='\begin{quote}';
      if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify)
      
      %find the closingquote
      closing_quote=char_to_verify;
      j=1;
      while j>0
        closing_quote=closing_quote+1;
        if strcmp(file(closing_quote:closing_quote+length('\end{quote}')-1),'\end{quote}')
          j=j-1;
        elseif strcmp(file(closing_quote:closing_quote+length('\begin{quote}')-1),'\begin{quote}')
          j=j+1;
        endif
      endwhile
      
      file=[file(1:char_to_verify-1) ...
        sprintf('\n\n')...
        '<div style=' sprintf('''') 'margin: 10px 5px 10px 30px' sprintf('''') '>' ...
        file(char_to_verify+length('\begin{quote}'):closing_quote-1) ...
        '</div>' ...
        file(closing_quote+length('\end{quote}'):length(file))];
        
      char_to_verify=char_to_verify-1;
    endif
    %
    
    
    %let us check if we are at any other environment
    exp_to_verify = '\begin{';
    if char_to_verify < length(file)-length(exp_to_verify) +2 && strcmp(file(char_to_verify:char_to_verify+length(exp_to_verify)-1),exp_to_verify) 
      
      envtype_open_brac=char_to_verify+length('\begin{')-1;
      envtype_clos_brac=findclosingbrac(file,envtype_open_brac);
      
      %anything between those two is the environment type. This might have a star, QUE VAI SER COMPLETAMENTE IGNORADA.
      envtype=file(envtype_open_brac+1:envtype_clos_brac-1);
      
      if strcmp(envtype,'theorem') || strcmp(envtype,'theorem*')
        envidentifier='Teorema';
	  elseif strcmp(envtype,'definition')
	    envidentifier='Definição';
      else
        envidentifier='Não reconhecido!!!!!!!!!!!!!';
      endif
      
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
        oparg=[' (' file(oparg_open_brac+1:oparg_clos_brac-1) ')'];
      else
        oparg_clos_brac=envtype_clos_brac;
        oparg='';
      endif
      
      %Now the corresponding HTML code
      
      htmlenv= ['<div style=' sprintf('''') 'margin-bottom: 5px; margin-top: 5px; padding: 5px 5px 0 5px; border: 1px solid gray; border-radius: 5px;' sprintf('''') sprintf('>\n') ...
      '<b>' envidentifier '</b>' oparg '.'];
      
      %let us simply keep the parts before the i-th position, the rewritten environment, and whatever's after the environment has ended. New lines for paragraph
      
      file=[file(1:char_to_verify-1) htmlenv sprintf('\n\n') file(oparg_clos_brac+1:length(file))];
      
      %let us skip the characters we added;
      char_to_verify=char_to_verify+length(['<div style=' sprintf('''') 'margin-bottom: 5px; margin-top: 5px; padding: 5px 5px 0 5px; border: 1px solid gray; border-radius: 5px;' sprintf('''') sprintf('>\n') ...
      '<b>'])-1;
      
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
  %make tikzpictures. Requires ImageMagick, probably with conver; https://imagemagick.org/
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  k=strfind(file,'\begin{tikzpicture}');
  p=strfind(file,'\end{tikzpicture}');
  numberoftikz=length(k);
  tikzbar=waitbar(0,'Creating tikzpictures...');
  
  while length(k)>0
    
    waitbar((numberoftikz-length(k))/numberoftikz);
    
    disp([int2str(length(k)) ' tikz to go.'])
    
    tikz=file(k(length(k)):p(length(k))+length('\end{tikzpicture}')-1);
    %latexcommands=fileread('src/latex_commands');
    %latexcommands=latexcommands(strfind(latexcommands,'\begin{equation*}')(1)+length('\begin{equation*}'):strfind(latexcommands,'\end{equation*}')(1)-1);
    
    %tikz=strrep(tikz,'\greaterthan ','>');
    %tikz=strrep(tikz,'\smallerthan ','<');
	
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
      '\usepackage{tikz,pgfplots}  \usetikzlibrary{arrows}' sprintf('\n') ...
      '\usepackage{mathrsfs}' sprintf('\n') ...
      '\usepackage{ifthen}' sprintf('\n') ...
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
    %temp_tikz_im=imread([temp_tikz_filename '.png']);
    
    file=[file(1:open_eq-1) ...
    '<img src=' sprintf('''') temp_tikz_filename '.png' sprintf('''') ' style=' sprintf('''') 'width:40%%;margin:auto;display:block' sprintf('''') '>' sprintf('\n\n') ...
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
  
  disp('Creating hyperreferences.')
  k=strfind(file,'\href{');
  number_of_references=length(k);
  refbar=waitbar(0,'Creating hyperreferences...');
  announce=1;
  while length(k)>0
    open_fir_brac=k(length(k))+length('\href{')-1;
    
    clos_fir_brac=findclosingbrac(file,open_fir_brac);
    
	open_sec_brac=clos_fir_brac+1;
    clos_sec_brac=findclosingbrac(file,open_sec_brac);
	
    link=file(open_fir_brac+1:clos_fir_brac-1);
	ref_text=file(open_sec_brac+1:clos_sec_brac-1);
    
    file=[file(1:k(length(k))-1) ...
            '<a href=' sprintf('''') link sprintf('''') '>' ...
            ref_text '</a>' ...
            file(clos_sec_brac+1:length(file))];
    
    k(length(k))=[];
    
    if (number_of_references-length(k))/number_of_references>announce/100
      waitbar((number_of_references-length(k))/number_of_references);
      announce=announce+1;
    endif
    
  endwhile
  
  close(refbar);
  
  
  
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
  
  disp('Building Moodle HTML.')
  
	file=[...
		'<!DOCTYPE html>' sprintf('\n') ...
		'<html>' sprintf('\n') ...
		'<head>' sprintf('\n') ...
		'<meta name=' sprintf('''') 'viewport' sprintf('''') ' content=' sprintf('''') 'width=device-width' sprintf('''') '>' sprintf('\n') ...
		'<script src=' sprintf('''') 'https://polyfill.io/v3/polyfill.min.js?features=es6' sprintf('''') '></script>' sprintf('\n') ...
		'<script id=' sprintf('''') 'MathJax-script' sprintf('''') ' async' sprintf('\n') ...
			'src=' sprintf('''') 'https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js' sprintf('''') '>' sprintf('\n') ...
		'</script>' sprintf('\n') ...
		'</head>' sprintf('\n') ...
		'<body>' sprintf('\n') ...
		file ...
		'</body>' sprintf('\n') ...
		'</html>' sprintf('\n') ...	
	];
  
    file=strrep(file,'\','\\'); %technical details
    curr_file=fopen([original_filename '_moodle.html'],'w');
    fprintf(curr_file,file);
    fclose(curr_file);
  
  disp('Done.')
  
endfunction