import SwiftUI
import GameController

private struct CloudGame: Identifiable {
    let id: String
    let title: String
    let service: String
    let symbol: String
    let url: String
}

struct HomeView: View {
    @AppStorage("favoriteIDs") private var favorites = ""
    @AppStorage("showFavoritesOnly") private var favoritesOnly = false
    @AppStorage("showControllerStatus") private var showControllerStatus = true
    @State private var tab = 0
    @State private var search = ""
    @State private var connectedControllers = GCController.controllers().count

    private let games: [CloudGame] = [
        .init(id: "xbox", title: "Xbox Cloud Gaming", service: "Xbox", symbol: "gamecontroller.fill", url: "https://www.xbox.com/play"),
        .init(id: "fortnite", title: "Fortnite (Xbox Cloud)", service: "Xbox", symbol: "bolt.fill", url: "https://www.xbox.com/play/games/fortnite/BT5P2X999VH2"),
        .init(id: "geforce", title: "GeForce NOW", service: "NVIDIA", symbol: "desktopcomputer", url: "https://play.geforcenow.com/"),
        .init(id: "luna", title: "Amazon Luna", service: "Luna", symbol: "moon.stars.fill", url: "https://luna.amazon.com/"),
        .init(id: "boosteroid", title: "Boosteroid", service: "Boosteroid", symbol: "cloud.fill", url: "https://cloud.boosteroid.com/")
    ]

    private var favoriteSet: Set<String> { Set(favorites.split(separator: ",").map(String.init)) }
    private var filtered: [CloudGame] {
        games.filter { game in
            (!favoritesOnly || favoriteSet.contains(game.id)) &&
            (search.isEmpty || game.title.localizedCaseInsensitiveContains(search) || game.service.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.025, green: 0.035, blue: 0.075).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("iGaming").font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(LinearGradient(colors: [.cyan, .purple], startPoint: .leading, endPoint: .trailing))
                        Text("CLOUD GAMING HUB").font(.system(size: 10, weight: .bold)).tracking(3).foregroundStyle(.gray)
                    }
                    Spacer()
                    Image(systemName: "gamecontroller.fill").font(.title2).foregroundStyle(.cyan)
                }.padding(.horizontal, 22).padding(.top, 16).padding(.bottom, 14)
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        if tab == 0 { gamesScreen }
                        else if tab == 1 { accountsScreen }
                        else { settingsScreen }
                    }.padding(.horizontal, 20).padding(.bottom, 30)
                }
                HStack(spacing: 0) {
                    tabButton("Juegos", "square.grid.2x2.fill", 0)
                    tabButton("Cuentas", "person.crop.circle", 1)
                    tabButton("Ajustes", "gearshape.fill", 2)
                }.padding(.top, 12).padding(.bottom, 8).background(Color(red: 0.06, green: 0.07, blue: 0.12))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .GCControllerDidConnect)) { _ in connectedControllers = GCController.controllers().count }
        .onReceive(NotificationCenter.default.publisher(for: .GCControllerDidDisconnect)) { _ in connectedControllers = GCController.controllers().count }
    }

    private var gamesScreen: some View {
        VStack(alignment: .leading, spacing: 18) {
            if showControllerStatus {
                Label(connectedControllers > 0 ? "Mando conectado (\(connectedControllers))" : "Conectá un mando Bluetooth para jugar", systemImage: "gamecontroller")
                    .font(.caption).foregroundStyle(connectedControllers > 0 ? .green : .gray)
            }
            TextField("Buscar juegos o servicios...", text: $search)
                .padding(13).background(.white.opacity(0.08)).cornerRadius(8)
            Toggle("Solo favoritos", isOn: $favoritesOnly).tint(.cyan).font(.subheadline)
            Text("Juegos y servicios").font(.title2.bold())
            ForEach(filtered) { game in
                HStack(spacing: 14) {
                    Image(systemName: game.symbol).font(.title).frame(width: 48, height: 58)
                        .foregroundStyle(.cyan).background(.cyan.opacity(0.09)).cornerRadius(7)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(game.title).font(.headline)
                        Text(game.service).font(.caption).foregroundStyle(.gray)
                        Button("JUGAR  ↗") { open(game.url) }.font(.caption.bold()).foregroundStyle(.cyan)
                    }
                    Spacer(minLength: 2)
                    Button { toggleFavorite(game.id) } label: {
                        Image(systemName: favoriteSet.contains(game.id) ? "star.fill" : "star")
                            .foregroundStyle(.yellow).padding(8)
                    }.accessibilityLabel("Alternar favorito")
                }.padding(12).background(.white.opacity(0.065)).cornerRadius(8)
            }
            if filtered.isEmpty { Text("No hay resultados.").foregroundStyle(.gray) }
            Text("Los juegos se abren mediante los enlaces oficiales. La disponibilidad depende del servicio, tu cuenta, región y compatibilidad con iOS.")
                .font(.caption).foregroundStyle(.gray)
        }
    }

    private var accountsScreen: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Cuentas").font(.title2.bold())
            Text("Iniciá sesión de forma segura en la página oficial de cada servicio. iGaming no solicita ni guarda contraseñas.")
                .foregroundStyle(.gray).font(.subheadline)
            serviceButton("Xbox / Microsoft", "https://www.xbox.com/play", "gamecontroller.fill")
            serviceButton("NVIDIA GeForce NOW", "https://play.geforcenow.com/", "desktopcomputer")
            serviceButton("Amazon Luna", "https://luna.amazon.com/", "moon.stars.fill")
            serviceButton("Boosteroid", "https://cloud.boosteroid.com/", "cloud.fill")
        }
    }

    private var settingsScreen: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ajustes").font(.title2.bold())
            Toggle("Mostrar estado del mando", isOn: $showControllerStatus).tint(.cyan)
            Toggle("Mostrar solo favoritos", isOn: $favoritesOnly).tint(.cyan)
            Text("Mandos: conectalos en Ajustes de iOS > Bluetooth. Los controles dentro de cada juego dependen del servicio.")
                .foregroundStyle(.gray).font(.subheadline)
            Text("iGaming 1.0 · Lanzador de servicios de cloud gaming")
                .foregroundStyle(.gray).font(.caption)
        }
    }

    private func serviceButton(_ title: String, _ url: String, _ symbol: String) -> some View {
        Button { open(url) } label: {
            HStack { Image(systemName: symbol).foregroundStyle(.cyan).frame(width: 28); Text(title); Spacer(); Image(systemName: "arrow.up.right") }
                .padding(17).background(.white.opacity(0.075)).cornerRadius(8)
        }.foregroundStyle(.white)
    }

    private func tabButton(_ title: String, _ symbol: String, _ index: Int) -> some View {
        Button { withAnimation(.easeInOut(duration: 0.2)) { tab = index } } label: {
            VStack(spacing: 5) { Image(systemName: symbol).font(.system(size: 20)); Text(title).font(.caption2.bold()) }
                .foregroundStyle(tab == index ? .cyan : .gray).frame(maxWidth: .infinity)
        }
    }

    private func toggleFavorite(_ id: String) {
        var set = favoriteSet
        if set.contains(id) { set.remove(id) } else { set.insert(id) }
        favorites = set.sorted().joined(separator: ",")
    }

    private func open(_ url: String) {
        guard let address = URL(string: url), ["https"].contains(address.scheme?.lowercased() ?? "") else { return }
        UIApplication.shared.open(address)
    }
}
