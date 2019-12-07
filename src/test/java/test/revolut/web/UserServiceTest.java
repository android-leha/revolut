package test.revolut.web;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;
import org.mockito.Answers;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.web.server.ResponseStatusException;

import java.time.DateTimeException;
import java.time.LocalDate;
import java.util.Optional;
import java.util.stream.Stream;

import static org.mockito.Mockito.when;

@SpringBootTest
class UserServiceTest {

    static final LocalDate TODAY = LocalDate.of(2019, 11, 30);

    @Mock
    UserRepository userRepository;

    @Mock(answer = Answers.CALLS_REAL_METHODS)
    DateProvider dateProvider;

    @InjectMocks
    UserService userService;

    @Test
    void addValidUser() {
        userService.add("alex", LocalDate.of(1986,1, 19));
    }

    @Test
    void addNonValidUser() {
        Assertions.assertThrows(DateTimeException.class, () -> {
            userService.add("alex", LocalDate.now());
        });
    }

    @Test
    void getUserNotFound() {
        when(userRepository.findById(Mockito.anyString())).thenReturn(Optional.empty());
        Assertions.assertThrows(ResponseStatusException.class, () -> {
            userService.getUser("nouser");
        });
    }

    @ParameterizedTest
    @MethodSource("listOfDaysAndDates")
    void getDaysUntilBirthday(int days, LocalDate date) {
        when(dateProvider.now()).thenReturn(TODAY);
        when(userRepository.findById(Mockito.anyString())).thenReturn(Optional.of(new User("test", date)));
        Assertions.assertEquals(days, userService.getDaysUntilBirthday("test"));
    }

    private static Stream<Arguments> listOfDaysAndDates() {
        return Stream.of(
                Arguments.of(50, LocalDate.of(1986, 1, 19)),
                Arguments.of(187, LocalDate.of(1987, 6, 4)),
                Arguments.of(288, LocalDate.of(2017, 9, 13)),
                Arguments.of(0, LocalDate.of(2019, 11, 30)),
                Arguments.of(1, LocalDate.of(2017, 12, 1))
        );
    }
}