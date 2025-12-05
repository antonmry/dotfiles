-- Lua Compiler File
-- Compiler: maven

if vim.g.current_compiler then
  return
end
vim.g.current_compiler = "maven"

vim.o.makeprg = "mvn"

vim.o.errorformat = table.concat({
  "%-G[INFO] %.%#",
  "%-G[debug] %.%#",
  "[FATAL] Non-parseable POM %f: %m%\\s%\\+@%.%#line %l\\, column %c%.%#",
  "[%tRROR] Malformed POM %f: %m%\\s%\\+@%.%#line %l\\, column %c%.%#",
  "[%tARNING] %f:[%l\\,%c] %m",
  "[%tRROR] %f:[%l\\,%c] %m",
  "%+E%>[ERROR] %.%\\+Time elapsed:%.%\\+<<< FAILURE!",
  "%+E%>[ERROR] %.%\\+Time elapsed:%.%\\+<<< ERROR!",
  "%+Z%\\s%#at %f(%\\f%\\+:%l)",
  "%+C%.%#"
}, ",")

-- Additional settings or configurations can be added here if needed
