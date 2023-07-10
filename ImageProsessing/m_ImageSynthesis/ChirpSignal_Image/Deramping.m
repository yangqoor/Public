%%
%{
            Kianoush Aqabakee
          student ID: 9512103311
%}
%%
function sc = Deramping(f0, chirp)
    s = conv(f0, chirp, 'same');
    sc = abs(conv(conj(s), flip(chirp), 'same'));
    %sc=abs(conv((s),flip(chirp),'same'));
end
