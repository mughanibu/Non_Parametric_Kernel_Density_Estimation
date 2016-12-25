function S = g_score(distMtx,n,lambda)
S=0;
for i=1:n
    phat=0;
    for j=1:n
        if (j~=i) % important
            phat= phat + normpdf(distMtx(i,j),0,lambda);
        end
    end
    phat = phat/(n-1);
    sum=0;
    for j=1:n
        if (j~=i)
            sum = sum + normpdf(distMtx(i,j),0,lambda)*(distMtx(i,j)*distMtx(i,j)/(lambda*lambda)-1);
        end
    end
    S = S + 1/(phat*(n-1)*lambda*sum);
end
end