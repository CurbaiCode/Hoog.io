function love.conf(t)
    t.title = "Hoog.io"
    t.gammacorrect = true
    t.window.width = 960
    t.window.height = 540
    t.window.resizable = true
    t.window.minwidth = 270
    t.window.minheight = 270

    t.modules.audio = false    -- Enable the audio module (boolean)
    t.modules.data = true      -- Enable the data module (boolean)
    t.modules.event = true     -- Enable the event module (boolean)
    t.modules.font = true      -- Enable the font module (boolean)
    t.modules.graphics = true  -- Enable the graphics module (boolean)
    t.modules.image = true     -- Enable the image module (boolean)
    t.modules.joystick = false -- Enable the joystick module (boolean)
    t.modules.keyboard = true  -- Enable the keyboard module (boolean)
    t.modules.math = true      -- Enable the math module (boolean)
    t.modules.mouse = true     -- Enable the mouse module (boolean)
    t.modules.physics = true   -- Enable the physics module (boolean)
    t.modules.sound = false    -- Enable the sound module (boolean)
    t.modules.system = true    -- Enable the system module (boolean)
    t.modules.thread = false   -- Enable the thread module (boolean)
    t.modules.timer = true     -- Enable the timer module (boolean), Disabling it will result 0 delta time in love.update
    t.modules.touch = true     -- Enable the touch module (boolean)
    t.modules.video = false    -- Enable the video module (boolean)
    t.modules.window = true    -- Enable the window module (boolean)
end
