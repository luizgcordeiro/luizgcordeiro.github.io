function emphtoem(originalfile)
%this program will change '\emph{...}' by '<em>...</em>' in file 'originalfile'

file=fileread(originalfile);	%first we load 'originalfile' as a string
str='\emph{';                   %this is the first part of the string that we will change
strsize=size(str,2);  %save its size for simplicity

%let us find the '\emph{'s

i=1;
while i<size(file,2)-size(str,2)+1
	if file(i:i+strsize-1)==str %this is to check if '\emph{' has appeared at the i-th character
		%now we will need to find where the '\emph' is closing. We need to look for a '}'. However, there could be some code in the midde, for example it to be '\emph{Hi, \emph{man}}', or '\emph{\uline{cool}}'. So we should not just look for the next '}'. Similarly, there could be something such as '\{' or '\}' inside, so we will ignore those.
		brac=0;
		
		%let us count how many brackets are open and closed. An open bracket will add 1 to brac while a closed bracket will subtract 1 from brac. When brac reaches -1, this will mean that we have found the bracket closing the '\emph'
		
		j=i+strsize-1;	%this is the position of the last character of the string
		while brac>-1
			j=j+1;		%look at the next character
      if (file(j)=='{') && (file(j-1)!='\')
			  brac=brac+1;
			elseif (file(j)=='}') && (file(j-1)!='\')
			  brac=brac-1;
			endif
		endwhile
		%when this 'while' breaks this means that 'j' is the current closing bracket for the '\emph'
		%let us simply keep the parts before the i-th position, inside the '\emph', and after the j-th position, and add the new code accordingly
		
		file=[file(1:i-1) '<em>' file(i+strsize:j-1) '</em>' file(j+1:size(file,2))];
		%let us skip the characters we added; notice that we add 1 at the end of the 'while'
		i=i+size('<em>',2)-1;
	endif
	i=i+1;
endwhile

%now we save the file

newfile=fopen([originalfile '_converted'],'w'); %create/empty file 'originalfile_converted'
file=strrep(file,'\','\\'); %technical details
file=strrep(file,'%','%%'); %technical details
fprintf(newfile,file);
fclose(newfile);

endfunction