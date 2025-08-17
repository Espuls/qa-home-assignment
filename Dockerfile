# Use imagem oficial do .NET para build e runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copie os arquivos de projeto e restaure dependências
COPY ["CardValidation.Web/CardValidation.Web.csproj", "CardValidation.Web/"]
COPY ["CardValidation.Core/CardValidation.Core.csproj", "CardValidation.Core/"]
COPY ["CardValidation.Core.Services/CardValidation.Core.Services.csproj", "CardValidation.Core.Services/"]
COPY ["CardValidation.Infrustructure/CardValidation.Infrustructure.csproj", "CardValidation.Infrustructure/"]
COPY ["CardValidation.ViewModels/CardValidation.ViewModels.csproj", "CardValidation.ViewModels/"]
RUN dotnet restore "CardValidation.Web/CardValidation.Web.csproj"

# Copie o restante do código
COPY . .

WORKDIR "/src/CardValidation.Web"
RUN dotnet publish "CardValidation.Web.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "CardValidation.Web.dll"]