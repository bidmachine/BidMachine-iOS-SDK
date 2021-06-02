import Foundation

public
class Git {
    
    let path: String
    
    init?(absolute path: String?) {
        guard
            let path = path,
            File.exist(File.path(with: path, ".git"))
        else {
            Log.println("Can't find git dir dir at path: \(String(describing: path))", .failure)
            return nil
        }
        self.path = path
    }
}

private
extension Git {
    func defaultComand() -> [String] {
        return ["git", "-C", self.path]
    }
}

public
extension Git {
    
    @discardableResult
    func status() -> Bool {
        return Shell.shell(self.defaultComand() + ["status"])
    }
    
    @discardableResult
    func existTag(_ name: String) -> Bool {
        return Shell.shell(self.defaultComand() + ["show-ref", "--tags", "--quiet", "--verify", "--", "refs/tags/\(name)"])
    }
    
    @discardableResult
    func createTag(_ name: String, _ description: String, _ remote: Bool) -> Bool {
        return
            self._createTag(name, description) &&
            (!remote || (remote && self._createRemoteTag(name)))
    }
    
    
    
    @discardableResult
    func deleteTag(_ name: String, _ remote: Bool) -> Bool {
        return
            self._deleteTag(name) &&
            (!remote || (remote && self._deleteRemoteTag(name)))
    }
}

private
extension Git {
    
    @discardableResult
    func _createTag(_ name: String, _ description: String) -> Bool {
        return Shell.shell(self.defaultComand() + ["tag", "-a", name, "-m", description])
    }
    
    @discardableResult
    func _deleteTag(_ name: String) -> Bool {
        return Shell.shell(self.defaultComand() + ["tag", "-d", name])
    }
    
    @discardableResult
    func _createRemoteTag(_ name: String) -> Bool {
        return Shell.shell(self.defaultComand() + ["push", "origin", name])
    }
    
    @discardableResult
    func _deleteRemoteTag(_ name: String) -> Bool {
        return Shell.shell(self.defaultComand() + ["push", "--delete", "origin", name])
    }
}
