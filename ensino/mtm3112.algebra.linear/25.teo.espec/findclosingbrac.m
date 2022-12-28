%this function finds the closing bracket in 'text', which has an open bracket in entry 'entry'
%this is a supplemental function for 'latex to html'

function c = findclosingbrac(text,entry)
  c=entry;
  if strcmp(text(entry),'[')
    cl=']';
  elseif strcmp(text(entry),'{')
    cl='}';
  endif
  
  brac=0;
  while brac>-1 && c<length(text)
    c=c+1;
    if (strcmp(text(c),text(entry))) && (1-strcmp(text(c-1),'\'))
      brac=brac+1;
    elseif (strcmp(text(c),cl)) && (1-strcmp(text(c-1),'\'))
      brac=brac-1;
    endif
  endwhile
  
  if brac>-1
    disp(['error when trying to find closing bracket next to entry' int2str(c)])
  endif
endfunction