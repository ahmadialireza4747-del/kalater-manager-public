# backend/src/KalateManager.Api/Dockerfile
# Foundation-System / Scaffold-Module: Multi-stage Docker build for ASP.NET Core 8.0 API.

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["KalateManager.Api.csproj", "./"]
RUN dotnet restore "KalateManager.Api.csproj"
COPY . .
RUN dotnet publish "KalateManager.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
EXPOSE 8080
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "KalateManager.Api.dll"]
