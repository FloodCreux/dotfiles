---@brief
---
--- https://github.com/razzmatazz/csharp-language-server
---
--- Language Server for C#.
---
--- csharp-ls requires the [dotnet-sdk](https://dotnet.microsoft.com/download) to be installed.
---
--- The preferred way to install csharp-ls is with `dotnet tool install --global csharp-ls`.

return {
	cmd = { "csharp-ls" },
	root_markers = { "*.sln", "*.slnx", "*.csproj" },
	filetypes = { "cs", "razor" },
	init_options = {
		AutomaticWorkspaceInit = true,
	},
}
