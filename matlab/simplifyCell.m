% function out = simplifyCell(c)
% unwrap nested cell structure when doing regexp

function out = simplifyCell(c)

out = c;

if(~isempty(c))
    
    if(iscell(c))
        
        if(iscell(c{1}))
            
            out = cell(1,length(c));
            
            for i=1:length(c)
                               
                out{i} = c{i}{1};
            end
                        
        end
    end
end