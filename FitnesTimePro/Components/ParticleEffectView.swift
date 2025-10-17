import SwiftUI

struct ParticleEffectView: View {
    @State private var particles: [Particle] = []
    let center: CGPoint
    let color: Color
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(color)
                    .frame(width: particle.size, height: particle.size)
                    .scaleEffect(particle.scale)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onAppear(perform: createParticles)
    }
    
    private func createParticles() {
        for _ in 0..<40 {
            let particle = Particle(center: center)
            particles.append(particle)
            
            let randomDelay = Double.random(in: 0...0.1)
            let randomDuration = Double.random(in: 0.6...1.2)
            
            withAnimation(.easeOut(duration: randomDuration).delay(randomDelay)) {
                let index = particles.count - 1
                if index < particles.count {
                    particles[index].isActive = false
                    particles[index].scale = 0
                    particles[index].opacity = 0
                }
            }
        }
    }
    
    private struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var size: CGFloat
        var scale: CGFloat = 1.0
        var opacity: Double = 1.0
        var isActive = true
        
        init(center: CGPoint) {
            let angle = Angle.degrees(Double.random(in: 0...360))
            let radius = CGFloat.random(in: 20...100)
            let x = center.x + radius * cos(CGFloat(angle.radians))
            let y = center.y + radius * sin(CGFloat(angle.radians))
            
            self.position = CGPoint(x: x, y: y)
            self.size = CGFloat.random(in: 5...15)
        }
    }
} 