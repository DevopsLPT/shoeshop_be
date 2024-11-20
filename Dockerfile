FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app
COPY . .
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS deploy
WORKDIR /deploy

ARG db_server
ENV ConnectionStrings__UserAppCon=$db_server

RUN useradd -r backend && chown -R backend. /deploy

USER backend

COPY --from=build --chown=backend:backend /app/out/ /deploy/

EXPOSE 5214

ENTRYPOINT ["dotnet", "backend.dll", "--urls", "http://0.0.0.0:5214"]