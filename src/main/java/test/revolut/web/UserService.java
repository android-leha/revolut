package test.revolut.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.DateTimeException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Optional;

import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
public class UserService {


    private final DateProvider dateProvider;

    private final UserRepository userRepository;

    @Autowired
    public UserService(DateProvider dateProvider, UserRepository userRepository) {
        this.dateProvider = dateProvider;
        this.userRepository = userRepository;
    }


    public void add(String name, LocalDate dateOfBirth) {
        LocalDate today = getNow();
        if (dateOfBirth.compareTo(today) >= 0) {
            throw new DateTimeException("Date should be less then today");
        }
        userRepository.save(new User(name, dateOfBirth));
    }

    public User getUser(String name) {
        Optional<User> user = userRepository.findById(name);
        if (user.isPresent()) {
            return user.get();
        } else {
            throw new ResponseStatusException(NOT_FOUND, "Unable to find user " + name);
        }
    }

    public long getDaysUntilBirthday(String name) {
        User user = getUser(name);
        return countDaysLeft(user.getDateOfBirth());
    }

    private long countDaysLeft(LocalDate dateOfBirth) {
        LocalDate today = getNow();
        LocalDate next = dateOfBirth.withYear(today.getYear());
        if (next.isBefore(today)) {
            next = next.plusYears(1);
        }
        return ChronoUnit.DAYS.between(today, next);
    }

    private LocalDate getNow() {
        return dateProvider.now();
    }
}
