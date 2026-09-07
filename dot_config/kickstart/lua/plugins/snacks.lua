return {
  'folke/snacks.nvim',
  priority = 1000,
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = [[
         _             _       _    _            _        _        _            _      _               
        _\ \          / /\    / /\ /\ \         /\ \     /\ \     /\ \         /\ \   /\_\             
       /\__ \        / / /   / / //  \ \       /  \ \    \ \ \    \_\ \       /  \ \ / / /         _   
      / /_ \_\      / /_/   / / // /\ \ \     / /\ \ \   /\ \_\   /\__ \     / /\ \ \\ \ \__      /\_\ 
     / / /\/_/     / /\ \__/ / // / /\ \ \   / / /\ \_\ / /\/_/  / /_ \ \   / / /\ \ \\ \___\    / / / 
    / / /         / /\ \___\/ // / /  \ \_\ / / /_/ / // / /    / / /\ \ \ / / /  \ \_\\__  /   / / /  
   / / /         / / /\/___/ // / /   / / // / /__\/ // / /    / / /  \/_// / /   / / // / /   / / /   
  / / / ____    / / /   / / // / /   / / // / /_____// / /    / / /      / / /   / / // / /   / / /    
 / /_/_/ ___/\ / / /   / / // / /___/ / // / /   ___/ / /__  / / /      / / /___/ / // / /___/ / /     
/_______/\__\// / /   / / // / /____\/ // / /   /\__\/_/___\/_/ /      / / /____\/ // / /____\/ /      
\_______\/    \/_/    \/_/ \/_________/ \/_/    \/_________/\_\/       \/_________/ \/_________/       
 ]],
      },
      sections = {
        { section = 'header' },
        {
          text = { "[error TS2533: 'lhoptiou' is possibly 'null' or 'undefined'.]", hl = 'header' },
          align = 'center',
          gap = 1,
          padding = 1,
        },
        { section = 'keys', gap = 1, padding = 1 },
        { section = 'startup' },
      },
    },
    -- indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    words = { enabled = true },
  },
}
