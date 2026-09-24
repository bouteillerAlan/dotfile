return {
      "mfussenegger/nvim-dap",
      lazy = false,
      config = function()
        local dap = require("dap")

        dap.adapters["pwa-node"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = { "/home/a2n/.dap/js-debug/src/dapDebugServer.js", "${port}" },
          },
        }

        dap.adapters["reactnativedirect"] = require("dap-react-native").create_adapter(dap.adapters["pwa-node"])

        for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
          dap.configurations[ft] = dap.configurations[ft] or {}
          table.insert(dap.configurations[ft], {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          })
          table.insert(dap.configurations[ft], {
            type = "pwa-node",
            request = "launch",
            name = "Launch file (tsx)",
            runtimeExecutable = "tsx",
            program = "${file}",
            cwd = "${workspaceFolder}",
          })
          table.insert(dap.configurations[ft], {
            type = "pwa-node",
            request = "attach",
            name = "Attach NestJS (9229)",
            cwd = "${workspaceFolder}",
            port = 9229,
          })
          table.insert(dap.configurations[ft], {
            type = "reactnativedirect",
            request = "attach",
            name = "RN: Attach Hermes",
            cwd = "${workspaceFolder}",
          })
        end

        -- change the default B for the point to an actual red point
        vim.api.nvim_set_hl(0, 'DapBreakpointRed', { fg = '#f7768e' })
        vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpointRed' })
        vim.fn.sign_define('DapBreakpointCondition', { text = '●', texthl = 'DapBreakpointRed' })
        vim.fn.sign_define('DapBreakpointRejected', { text = '●', texthl = 'DapError' })
        vim.fn.sign_define('DapLogPoint', { text = '●', texthl = 'DapLogPoint' })
        vim.fn.sign_define('DapStopped', { text = '●', texthl = 'DapStopped' })

        local keymap = vim.keymap.set
        keymap("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
        keymap("n", "<leader>dc", dap.continue, { desc = "Continue / launch" })
        keymap("n", "<leader>do", dap.step_over, { desc = "Step over" })
        keymap("n", "<leader>di", dap.step_into, { desc = "Step into" })
        keymap("n", "<leader>du", dap.step_out, { desc = "Step out" })
        keymap("n", "<leader>dt", dap.terminate, { desc = "Terminate session" })
        keymap("n", "<leader>dr", function() dap.repl.toggle() end, { desc = "DAP repl" })
      end,
    }
