using Godot;
using System;

public partial class robot : Sprite2D
{
    private Vector2 viewportSize;
    private Vector2 spriteHalfSize;
    
    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        GD.Print("Hello, World!2");
        Node bgNode = GetNode("../BG");
        bgNode.Connect("test_signal", new Callable(this, "_on_TestSignal_received"));
        
        GD.Print("Hello, World!3");
        viewportSize = GetViewportRect().Size;

        // 設置精靈的中心點
        spriteHalfSize = this.Texture.GetSize() / 2;
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(double delta)
    {
        this.RotationDegrees += 90 * (float)delta;
        
        Vector2 movement = Vector2.Zero;

        if (Input.IsKeyPressed(Key.Up))
        {
            movement += Vector2.Up * 10;
        }
        if (Input.IsKeyPressed(Key.Down))
        {
            movement += Vector2.Down * 10;
        }
        if (Input.IsKeyPressed(Key.Left))
        {
            movement += Vector2.Left * 10;
        }
        if (Input.IsKeyPressed(Key.Right))
        {
            movement += Vector2.Right * 10;
        }
        
        // 應用移動並限制在視窗範圍內，考慮精靈的大小
        this.Position = (this.Position + movement).Clamp(
            spriteHalfSize,
            viewportSize - spriteHalfSize
        );
    }

    // 處理信號接收到時的事件
    private void _on_TestSignal_received(int testArg)
    {
        GD.Print($"Received from BG with value: {testArg}");
    }
}
