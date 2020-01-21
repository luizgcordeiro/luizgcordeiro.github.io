function convenv(originalfile)
%this function will convert the latex code
%'\begin{<ENVTYPE>}[<OPARG>]\label{<LABEL>}...\end{<ENVTYPE>}' by the corresponding code <div class='ENVTYPE'>...</div> in 'originalfile'
%This function will also check for the optional argument and possible label. If no label has been given, it will automatically generate one.
%All environments under consideration will use the same counter.

environmentstoconsider={'theorem','example','definition'};
%this is a cell array with the environments under consideration. To call the i-th environment as a string, use 'char(environmentstoconsider(i))'.

file=fileread(originalfile);	%first we load 'originalfile' as a string

%Let us find where the environments are started

counter=0; %this is the counter

i=1;
while i<length(file)-length('\begin{')+1
	if file(i:i+7-1)=='\begin{' %this is to check if an environment has started at the i-th character
		%now we will need to find which type of environment it is. We need to look for a '}'. However, there could be some code in the midde, or something such as '\{' or '\}' inside, so we will ignore those.
		brac=0;
		
		%let us count how many brackets are open and closed. An open bracket will add 1 to brac while a closed bracket will subtract 1 from brac. When brac reaches -1, this will mean that we have found the bracket closing the '\begin{...}'
		
		j=i+7-1;	%this is the position of the last character of '\begin{'
		while brac>-1
			j=j+1;		%look at the next character
      if (file(j)=='{') && (file(j-1)!='\')
			  brac=brac+1;
			elseif (file(j)=='}') && (file(j-1)!='\')
			  brac=brac-1;
			endif
		endwhile
		%when this 'while' breaks this means that 'j' is the current closing bracket for the '\begin{...}'
    %anything in the middle will be the environment type
    envtype=file(i+7:j-1);
    
    %let us garantee we are not in an 'enumerate' or 'itemize'
    if 1-strcmp(envtype,'enumerate') && 1-strcmp(envtype,'itemize')
      %Nice. So now we need to check if there is an optional argument.
      oparg='';
      k=j;  %This is the same position as the end of '\begin{...}'. This will change to the end of '[...]' if there is an optional argument.
      %We do this for later, when we look for a label
      if file(j+1)=='['
        %we repeat the process: let us find out where this bracket is closing. Note that, since '\[...\]' is equivalent to '\begin{equation*}...\end{equation*}' (with amsmath)
        brac=0;
        
        k=j+1;  %this is the position of the '['
        while brac>-1
          k=k+1;		%look at the next character
          if (file(k)=='[')
            brac=brac+1;
          elseif (file(k)==']')
            brac=brac-1;
          endif
        endwhile
        %Now, let us save the optional argument. If the optional argument is empty, this will break the program.
        oparg=file(j+1+1:k-1);
      endif
      
      %Now let us look for the label
      label='';
      p=k;  %this will be the end of \begin{...}, if there is no optional argument or the end of [...] if there is one. It will change to the end of '\label{...}' if there is a label.
      if file(k+1:k+7)=='\label{'
        brac=0;
        p=k+7;  %position of the last character of '\label{'
        while brac>-1
          p=p+1;
          if (file(p)=='{') && (file(p-1)!='\')
            brac=brac+1;
          elseif (file(p)=='}') && (file(p-1)!='\')
            brac=brac-1;
          endif
        endwhile
        label=file(k+7+1:p-1);
      endif
      
      %Cool. Now we have ENVTYPE, OPARG and LABEL (in lowercaps), possibly being empty. Positions i,j,k,p are also well-set, as above:
      %\begin{envtype}[...]\label{...}
      %i             j    k          p
      %Let us look for the end of the environment
      q=p;
      while 1-strcmp(file(q:q+length(['\end{' envtype '}'])-1),['\end{' envtype '}'])
        q=q+1;
      endwhile
      %number q is the position of the beggining of '\end{...}'.
      
      %Now the corresponding HTML code
      if strcmp(envtype,'definition')
        envidentifier='Definition';
      elseif strcmp(envtype,'theorem')
        envidentifier='Theorem';
      elseif strcmp(envtype,'example')
        envidentifier='Example';
      elseif strcmp(envtype,'proposition')
        envidentifier='Proposition';
      elseif strcmp(envtype,'lemma')
        envidentifier='Lemma';
      elseif strcmp(envtype,'exercise')
        envidentifier='Exercise';
      elseif strcmp(envtype,'solution')
        envidentifier='Solution';
      elseif strcmp(envtype,'proof')
        envidentifier='Proof';
      endif
      
      strcoutner='';
      if (1-strcmp(envtype,'solution')) && (1-strcmp(envtype,'proof'))
        counter=counter+1;
        strcounter=[' ' int2str(counter)];
      endif
      
      %let us do the label
      strlabel='';
      if strcmp(label,'') && 1-strcmp(envtype,'solution') && 1-strcmp(envtype,'proof')
        label = [envtype int2str(counter)];
        strlabel = [' id=' sprintf('''') label sprintf('''')];
      endif
      
      %let us do the optional arugment, if it exists
      if 1-strcmp(oparg,'')
        oparg = [' <span class=''envop''>(' oparg ')</span>'];
      endif
      
      %now the code. First we 
      htmlenv= ['<!-- ' int2str(counter) ' -->' sprintf('\n') ...
      '<div class=' sprintf('''') envtype sprintf('''') strlabel sprintf('>\n') ...
      '<p><span class=' sprintf('''') envidentifier sprintf('''') '>' envidentifier ' ' int2str(counter) oparg '</span>' ...
      file(p+1:q-1) ...
      sprintf(['</p>\n</div>'])];
      
      %let us simply keep the parts before the i-th position, the rewritten environment, and whatever's after the environemtn has ended
      
      file=[file(1:i-1) htmlenv file(q+length(['\end{' envtype '}']):length(file))];
      %let us skip the characters we added; notice that we add 1 at the end of the 'while'
      i=i+size(['\begin{' envtype '}'],2)-1;
    endif %this is the non-enumerate/itemize if
	endif
	i=i+1;
endwhile

%now we save the file

newfile=fopen(['conv_' originalfile],'w'); %create/empty file 'conv_originalfile'
file=strrep(file,'\','\\'); %technical details
file=strrep(file,'%','%%'); %technical details
fprintf(newfile,file);
fclose(newfile);

endfunction