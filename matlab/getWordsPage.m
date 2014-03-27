function out = getWordsPage(s)

s = lower(s);

%remove links
s = regexprep(s, '<a\s[^>]*?>', ' ');
s = regexprep(s, '</a>|</ a>', ' ');

%remove some common tags
tags = {'i','b','p','span','li','ul','h1','h2','h3'};
for i=1:length(tags)
 s = regexprep(s, ['<\s*' tags{i} '\s*>'], ' ');
 s = regexprep(s, ['<\s*/\s*' tags{i} '\s*>'],' ');
end

s = regexprep(s, '"',' ');
s = regexprep(s, '?',' ');
s = regexprep(s, '\s+',' ');

%
expr = '([A-Z0-9a-z .,!?''?"?$&:;-]*)';

[~, mat] = regexp(s, expr, 'tokens', 'match');

phraseLength = zeros(length(mat),1);
meanWordLength = zeros(length(mat),1);
fractionOfNumbers = zeros(length(mat),1);
fractionOfWeirdSigns = zeros(length(mat),1);

%%
for i=1:length(mat)


 p = mat{i};

 %compute fraction of numbers and of weird signs
 tmpNoNumbers = regexprep(p, '[^a-z]', ' ');%remove everything except A-Z

 Ntot = length( regexprep(p,'\s+','') );

 p = regexprep(p, '[^a-z0-9]', ' ');%remove everything except A-Z and numbers

 N1 = length( regexprep(tmpNoNumbers,'\s+','') );
 N2 = length( regexprep(p,'\s+','') );

 if( N2>0 )
     fractionOfNumbers(i) = (N2-N1)/N2;
 end

 if( Ntot>0 )
     fractionOfWeirdSigns(i) = (Ntot-N2)/Ntot;
 end

 words = regexp(p, '[\s*]', 'split');

 phraseLength(i) = length(words);

 if(~isempty(words))
     for j=1:length(words)

         meanWordLength(i) = meanWordLength(i) + length(words{j});

     end

     meanWordLength(i) = meanWordLength(i)/length(words);
 end

end

phrases = find(... 
             phraseLength > 10 & meanWordLength < 10 & ...
             meanWordLength > 3 & fractionOfNumbers < 0.1 & ...
             fractionOfWeirdSigns < 0.1);

out = unique(mat(phrases));
out = [out{:}];
if(~isempty(out))
out = regexprep(out, '[^a-z0-9-'']', ' ');
out = regexp(out, '[\s*\t*]', 'split');

out = out(~strcmp(out,''));
out = out(~strcmp(out,' '));
else
    
   out = {}; 
end


