-- ABOUTME: Smooth animated cursor that smears when moving
-- ABOUTME: Gives a fluid, modern feel to cursor movement
return {
  {
    "sphamba/smear-cursor.nvim",
    opts = {
      stiffness = 0.8,
      trailing_stiffness = 0.5,
      distance_stop_animating = 0.5,
      cursor_color = "#d3cdc3",
    },
  },
}
