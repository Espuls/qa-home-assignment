FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["CardValidation.Web/CardValidation.Web.csproj", "CardValidation.Web/"]
COPY ["CardValidation.Core/CardValidation.Core.csproj", "CardValidation.Core/"]
COPY ["CardValidation.Core.Tests/CardValidation.Core.Tests.csproj", "CardValidation.Core.Tests/"]
COPY ["CardValidation.Web.Tests/CardValidation.Web.Tests.csproj", "CardValidation.Web.Tests/"]
COPY ["CardValidation.IntegrationTests/CardValidation.IntegrationTests.csproj", "CardValidation.IntegrationTests/"]
RUN dotnet restore "CardValidation.Web/CardValidation.Web.csproj"

COPY . .

RUN dotnet test CardValidation.Core.Tests/CardValidation.Core.Tests.csproj --logger "html;LogFileName=core-tests.html" --results-directory /src/TestResults
RUN dotnet test CardValidation.Web.Tests/CardValidation.Web.Tests.csproj --logger "html;LogFileName=web-tests.html" --results-directory /src/TestResults
RUN dotnet test CardValidation.IntegrationTests/CardValidation.IntegrationTests.csproj --logger "html;LogFileName=integration-tests.html" --results-directory /src/TestResults

WORKDIR "/src/CardValidation.Web"
RUN dotnet publish "CardValidation.Web.csproj" -c Release -o /app/publish

RUN mkdir -p /app/publish/wwwroot/test-results \
    && cp /src/TestResults/*.html /app/publish/wwwroot/test-results/

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "CardValidation.Web.dll"]