# Use the official Microsoft .NET 10 SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build
WORKDIR /src

# Copy the project file and restore dependencies
COPY *.csproj ./
RUN dotnet restore

# Copy the rest of the code and build it
COPY . ./
RUN dotnet publish -c Release -o /app

# Use the matching lightweight ASP.NET 10 runtime image for final execution
FROM mcr.microsoft.com/dotnet/aspnet:10.0-preview AS runtime
WORKDIR /app
COPY --from=build /app .

# Expose the dynamic port Render gives us
EXPOSE 5000
ENV ASPNETCORE_URLS=http://0.0.0.0:5000

# Fix: Dynamically find the .dll name regardless of casing and launch it via a shell script
ENTRYPOINT ["sh", "-c", "dotnet $(ls *.runtimeconfig.json | sed 's/.runtimeconfig.json/.dll/')"]