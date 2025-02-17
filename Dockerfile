FROM mcr.microsoft.com/dotnet/sdk:6.0 
ARG db_server
ENV ConnectionStrings__UserAppCon=$db_server

WORKDIR /app
COPY . .
RUN dotnet restore

ENTRYPOINT ["dotnet", "run", "--urls", "http://0.0.0.0:5214"]