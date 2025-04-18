//
//  ActiveNavlogsView.swift
//  New_Foreflight
//
//  Created by John Foster on 4/13/25.
//

import SwiftUI


struct ActiveNavlogsView: View {
    
    // MARK: - ActiveNavlogsView
 
    @EnvironmentObject var activeNavlogsVM: ActiveNavlogsViewModel

        var body: some View {
            NavigationView {
                Group {
                    if activeNavlogsVM.activeNavlogs.isEmpty {
                        Text("NO active F plans.")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    } else {
                        List {
                            ForEach(activeNavlogsVM.activeNavlogs) { navLog in
                                NavigationLink(destination: NavLogView(navLog: navLog)) {
                                    NavlogRow(navLog: navLog)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Active Navlogs")
            }
        }
    
    
}
