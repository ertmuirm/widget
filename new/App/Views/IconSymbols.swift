import SwiftUI
import UIKit

// MARK: - Color Extension for Hex Strings

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let length = hexSanitized.count
        let r, g, b, a: Double
        
        if length == 8 {
            r = Double((rgb >> 24) & 0xFF) / 255.0
            g = Double((rgb >> 16) & 0xFF) / 255.0
            b = Double((rgb >> 8) & 0xFF) / 255.0
            a = Double(rgb & 0xFF) / 255.0
        } else if length == 6 {
            r = Double((rgb >> 16) & 0xFF) / 255.0
            g = Double((rgb >> 8) & 0xFF) / 255.0
            b = Double(rgb & 0xFF) / 255.0
            a = 1.0
        } else if length == 4 {
            r = Double((rgb >> 12) & 0xFF) / 255.0
            g = Double((rgb >> 8) & 0xFF) / 255.0
            b = Double((rgb >> 4) & 0xFF) / 255.0
            a = Double(rgb & 0xFF) / 255.0
        } else if length == 3 {
            r = Double((rgb >> 8) & 0xFF) / 255.0
            g = Double((rgb >> 4) & 0xFF) / 255.0
            b = Double(rgb & 0xFF) / 255.0
            a = 1.0
        } else {
            r = 0
            g = 0
            b = 0
            a = 1
        }
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else {
            return "#000000"
        }
        
        let r = components.count > 0 ? components[0] : 0
        let g = components.count > 1 ? components[1] : 0
        let b = components.count > 2 ? components[2] : 0
        
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

// MARK: - Predefined Colors

extension Color {
    static let widgetBlack = Color(hex: "#000000")
    static let widgetWhite = Color(hex: "#FFFFFF")
    
    static let predefinedColors: [Color] = [
        Color(hex: "#000000"), // Black
        Color(hex: "#FF5733"), // Orange Red
        Color(hex: "#33FF57"), // Lime Green
        Color(hex: "#3357FF"), // Blue
        Color(hex: "#FF33F5"), // Magenta
        Color(hex: "#F5FF33"), // Yellow
        Color(hex: "#FFFFFF"), // White
        Color(hex: "#808080"), // Gray
        Color(hex: "#1C1C1E"), // Dark Gray
        Color(hex: "#3A3A3C"), // Medium Gray
        Color(hex: "#636366"), // Light Gray
        Color(hex: "#FF9500"), // Orange
        Color(hex: "#FFCC00"), // Yellow
        Color(hex: "#34C759"), // Green
        Color(hex: "#007AFF"), // Blue
        Color(hex: "#AF52DE"), // Purple
        Color(hex: "#FF2D55"), // Pink
        Color(hex: "#FF3B30"), // Red
        Color(hex: "#00C7BE"), // Teal
    ]
    
    static let predefinedHexColors: [String] = [
        "#000000", "#FF5733", "#33FF57", "#3357FF", "#FF33F5",
        "#F5FF33", "#FFFFFF", "#808080", "#1C1C1E", "#3A3A3C",
        "#636366", "#FF9500", "#FFCC00", "#34C759", "#007AFF",
        "#AF52DE", "#FF2D55", "#FF3B30", "#00C7BE"
    ]
}

// MARK: - SF Symbols for Icons

enum IconSymbols {
    static let popular: [String] = [
        "house.fill", "gear", "star.fill", "heart.fill", "bookmark.fill",
        "bell.fill", "calendar", "clock.fill", "camera.fill", "envelope.fill",
        "phone.fill", "message.fill", "music.note", "play.fill", "pause.fill",
        "play.circle.fill", "folder.fill", "doc.fill", "trash.fill", "square.and.arrow.up",
        "square.and.arrow.down", "link", "lock.fill", "key.fill", "creditcard.fill",
        "cart.fill", "bag.fill", "creditcard", "dollarsign.circle.fill", "banknote.fill",
        "map.fill", "location.fill", "airplane", "car.fill", "figure.walk",
        "sun.max.fill", "moon.fill", "cloud.fill", "snow", "thermometer.sun.fill",
        "drop.fill", "wind", "bolt.fill", "flame.fill", "leaf.fill",
        "hare.fill", "tortoise.fill", "bird.fill", "fish.fill", "pawprint.fill",
        "ladybug.fill", "ant.fill", "leaf.arrow.triangle.circlepath", "globe", "map.fill",
        "safari.fill", "globe.americas.fill", "globe.europe.africa.fill", "globe.asia.australia.fill", "building.2.fill",
        "cross.fill", "cross.circle.fill", "staroflife.fill", "bandage.fill", "pills.fill",
        "bed.double.fill", "figure.rest", "figure.stand", "figure.run", "figure.walk",
        "figure.pool.swim", "bicycle", "car", "bus.fill", "tram.fill",
        "tram", "airplane.departure", "airplane.arrival", "fuelpump.fill", "wrench.fill",
        "hammer.fill", "paintbrush.fill", "paintpalette.fill", "scissors", "pencil",
        "pen", "highlighter", "eraser.fill", "ruler.fill", "square.grid.3x3.fill",
        "app.fill", "apps.fill", "square.grid.2x2.fill", "rectangle.grid.2x2.fill", "triangle.fill",
        "circle.fill", "star.fill", "moon.fill", "sun.max.fill", "cloud.fill",
        "snow", "flame.fill", "bolt.fill", "tornado", "humidity.fill", "barometer.fill",
        "thermometer.medium", "thermometer.high", "thermometer.low", "aqi.low", "aqi.medium", "aqi.high",
        "facemask.fill", "lungs.fill", "heart.text.square.fill", "waveform.path.ecg", "brain.head.profile",
        "stomach", "eye.fill", "ear.fill", "nose.fill", "mouth.fill",
        "eyebrow", "mustache.fill", "eyeglasses", "sunglasses.fill", "head.circle.fill",
        "person.fill", "person.2.fill", "person.3.fill", "figure.2", "figure.3",
        "figure.dress.line.vertical.figure", "figure.arms.open", "figure.coil", "figure.roll", "figure.slash",
        "figure.fall", "figure.climb", "figure.stairs", "figure.barre", "figure.yoga",
        "figure.flex", "figure.strengthtraining.traditional", "figure.strengthtraining.functional", "figure.core.training", "figure.circuit.training",
        "figure.hiking", "figure.outdoor.cycle", "figure.indoor.cycle", "figure.run", "figure.walk",
        "figure.stairs", "figure.step.training", "figure.boxing", "figure.martial.arts", "figure.cross.training",
        "figure.skiing.downhill", "figure.skiing.crosscountry", "figure.snowboarding", "figure.surfing", "figure.swim",
        "figure.water.polo", "figure.rowing", "figure.kayaking", "figure.canoeing", "figure.sailing",
        "figure.windsurfing", "figure.roller.skating", "figure.rollerblading", "figure.skateboarding", "figure.jumprope",
        "figure.bowling", "figure.golf.tee", "figure.golf", "figure.tennis", "figure.badminton",
        "figure.squash", "figure.tennisball", "figure.basketball", "figure.baseball", "figure.football",
        "figure.soccer", "figure.hockey", "figure.cricket", "figure.rugby", "figure.handball",
        "figure.volleyball", "figure.lacrosse", "figure.pingpong", "figure.archery", "figure.fencing",
        "figure.gymnastics", "figure.hand.ball", "figure.equestrian", "figure.bullride", "figure.ropeturning",
        "figure.cut.red", "figure.wakeboarding", "figure.wakesurf", "figure.kitesurfing", "figure.scuba diving",
        "figure.spinning", "figure.rowing.machine", "figure.jumprope", "figure.stair.steper", "figure.crosstrainer"
    ]
    
    static let categories: [String: [String]] = [
        "Home": ["house.fill", "house", "building.2.fill", "building.fill", "door.left.hand.open", "door.garage.open", "bed.double.fill", "sofa.fill", "chair.fill", "lamp.floor.fill", "lamp.desk.fill", "fan.floor.fill", "fan.desk.fill", "air.conditioner.horizontal.fill", "thermostat", "humidifier.fill", "dehumidifier.fill", "air.purifier.fill", "oven.fill", "refrigerator.fill", "dishwasher.fill", "washer.fill", "dryer.fill", "iron.fill"],
        "Settings": ["gear", "gearshape.fill", "gearshape.2.fill", "slider.horizontal.3", "dial.min", "dial.max", "switch.2", "toggle.power", "power", "lock.fill", "lock.open.fill", "key.fill", "key.radiowaves.forward", "wifi.router.fill", "router.fill", "server.rack", "printer.fill", "scanner.fill", "fax", "display", "desktopcomputer", "laptopcomputer", "keyboard.fill", "computermouse.fill"],
        "Communication": ["phone.fill", "phone.badge.checkmark", "phone.badge.plus", "phone.arrow.right.fill", "phone.arrow.down.left.fill", "message.fill", "message.badge.fill", "envelope.fill", "envelope.badge.fill", "mail.fill", "mail", "at", "paperplane.fill", "antenna.radiowaves.left.and.right", "telephone.receiver.fill", "telephone.receiver", "person.wave.2.fill", "person.text.rectangle.fill", "video.fill", "video.badge.checkmark", "video.badge.plus", "facetime", "contacts.fill"],
        "Social": ["person.fill", "person.2.fill", "person.3.fill", "person.crop.circle.fill", "person.crop.rectangle.fill", "person.badge.minus", "person.badge.plus", "person.fill.checkmark", "person.fill.questionmark", "figure.2.arms.open", "heart.fill", "heart", "heart.circle.fill", "star.fill", "star", "star.circle.fill", "bookmark.fill", "bookmark", "flag.fill", "flag", "person.2.heart.fill", "person.2.circle.fill", "person.2.person.2.fill", "rectangle.stack.person.crop.fill"],
        "Media": ["play.fill", "pause.fill", "stop.fill", "forward.fill", "backward.fill", "play.circle.fill", "play.square.fill", "play.rectangle.fill", "music.note", "music.note.list", "music.mic", "music.note.2", "headphones", "hifispeaker.fill", "hifispeaker", "airpods", "airpods.pro", "airpods.max", "homepod.fill", "homepodmini.fill", "speaker.wave.3.fill", "speaker.wave.2.fill", "speaker.wave.1.fill", "speaker.fill"],
        "Photos": ["camera.fill", "camera", "camera.metering.center.weighted", "camera.metering.partial", "camera.metering.spot", "camera.metering.multispot", "camera.metering.matrix", "viewfinder", "doc.text.viewfinder", "photo.fill", "photo", "photo.on.rectangle", "photo.on.rectangle.angled", "rectangle.on.rectangle.angled", "pano.fill", "livephoto", "livephoto.play", "camera.rotate.fill", "camera.filters", "sparkles", "wand.and.stars", "wand.and.rays", "crop", "crop.rotate", "aspectratio.fill", "skew"],
        "Calendar": ["calendar", "calendar.badge.plus", "calendar.badge.minus", "calendar.badge.clock", "calendar.badge.exclamationmark", "calendar.day.timeline.left", "calendar.day.timeline.right", "calendar.event.fill", "calendar.event", "datebadge.timelapse", "clock.fill", "clock", "timer", "alarm.fill", "alarm", "stopwatch.fill", "stopwatch", "hourglass", "clock.badge.exclamationmark.fill", "clock.badge.checkmark.fill", "moon.fill", "moon", "sun.max.fill", "sun.max", "sunrise.fill", "sunrise", "sunset.fill", "sunset"],
        "Weather": ["cloud.fill", "cloud", "cloud.sun.fill", "cloud.sun", "cloud.moon.fill", "cloud.moon", "cloud.bolt.fill", "cloud.bolt", "cloud.rain.fill", "cloud.rain", "cloud.drizzle.fill", "cloud.drizzle", "cloud.snow.fill", "cloud.snow", "cloud.hail.fill", "cloud.hail", "cloud.fog.fill", "cloud.fog", "moon.fill", "moon", "moon.circle.fill", "moon.circle", "sun.max.fill", "sun.max", "sun.min.fill", "sun.min", "smoke.fill", "smoke", "wind", "wind.circle.fill"],
        "Navigation": ["map.fill", "map", "map.circle.fill", "location.fill", "location", "location.north.fill", "location.circle.fill", "location.north.line.fill", "location.south.line.fill", "location.east.line.fill", "location.west.line.fill", "mappin", "mappin.circle.fill", "mappin.circle", "mappin.and.ellipse", "point.topleft.down.curvedto.point.bottomright.up.fill", "location.magnifyingglass", "binoculars.fill", "safari.fill", "globe", "globe.americas.fill", "globe.europe.africa.fill", "globe.asia.australia.fill", "airplane", "airplane.departure", "airplane.arrival", "car.fill", "car", "car.circle.fill"],
        "Shopping": ["cart.fill", "cart", "cart.badge.plus", "cart.badge.minus", "cart.badge.questionmark", "bag.fill", "bag", "bag.badge.plus", "bag.badge.minus", "bag.badge.questionmark", "creditcard.fill", "creditcard", "dollarsign.circle.fill", "dollarsign.circle", "banknote.fill", "banknote", "yensign.circle.fill", "yensign.circle", "eurosign.circle.fill", "eurosign.circle", "poundsign.circle.fill", "poundsign.circle", "wallet.pass.fill", "wallet.pass", "giftcard.fill", "giftcard", "tag.fill", "tag", "tag.circle.fill", "tag.circle"],
        "Health": ["heart.fill", "heart", "heart.circle.fill", "heart.circle", "waveform.path.ecg", "waveform.path", "pulse", "lungs.fill", "lungs", "brain.head.profile", "brain", "stomach", "mouth.fill", "mouth", "eye.fill", "eye", "eyebrow", "eyeglasses", "eyeglasses.fill", "sunglasses.fill", "cross.fill", "cross.circle.fill", "cross.vial.fill", "pills.fill", "pills", "pill.fill", "pill", "syringe.fill", "syringe", "facemask.fill", "facemask"],
        "Fitness": ["figure.run", "figure.walk", "figure.stand", "figure.rest", "figure.flex", "figure.yoga", "figure.barre", "figure.hiking", "figure.cycling", "figure.outdoor.cycle", "figure.indoor.cycle", "figure.swim", "figure.water.polo", "figure.rowing", "figure.climb", "figure.stairs", "figure.boxing", "figure.martial.arts", "figure.cross.training", "figure.core.training", "figure.strengthtraining.traditional", "figure.strengthtraining.functional", "figure.skiing.downhill", "figure.snowboarding", "figure.surfing", "figure.basketball", "figure.tennis", "figure.baseball", "figure.golf", "figure.soccer"],
        "Finance": ["dollarsign.circle.fill", "dollarsign.circle", "dollarsign.square.fill", "dollarsign.square", "banknote.fill", "banknote", "creditcard.fill", "creditcard", "wallet.pass.fill", "wallet.pass", "cart.fill", "cart", "chart.line.uptrend.xyaxis", "chart.line.downtrend.xyaxis", "chart.bar.fill", "chart.pie.fill", "chart.pie", "chart.doughnut.fill", "chart.doughnut", "chart.bar.xaxis", "building.columns.fill", "building.columns", "bitcoinsign.circle.fill", "bitcoinsign.circle", "dollarsign.arrow.circlepath", "eurosign.arrow.circlepath", "poundsign.arrow.circlepath", "yensign.arrow.circlepath", "percent", "aqi.above.level.fill"],
        "Productivity": ["doc.fill", "doc", "doc.text.fill", "doc.text", "doc.richtext.fill", "doc.richtext", "doc.plaintext.fill", "doc.plaintext", "doc.badge.plus", "doc.badge.minus", "doc.badge.gearshape", "doc.badge.clock", "doc.badge.ellipsis", "folder.fill", "folder", "folder.badge.plus", "folder.badge.minus", "folder.badge.questionmark", "tray.fill", "tray", "tray.badge.plus", "tray.badge.minus", "archivebox.fill", "archivebox", "shippingbox.fill", "shippingbox", "doc.on.doc.fill", "doc.on.doc", "doc.on.clipboard.fill", "doc.on.clipboard"],
        "Security": ["lock.fill", "lock", "lock.open.fill", "lock.open", "lock.circle.fill", "lock.circle", "lock.shield.fill", "lock.shield", "lock.shield.fill", "lock.shield", "key.fill", "key", "key.horizontal.fill", "key.horizontal", "wifi.passkey.fill", "wifi.passkey", "faceid", "touchid", "eye.fill", "eye", "eye.slash.fill", "eye.slash", "exclamationmark.triangle.fill", "exclamationmark.triangle", "checkmark.shield.fill", "checkmark.shield", "xmark.shield.fill", "xmark.shield", "shield.fill", "shield"]
    ]
}